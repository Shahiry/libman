<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.libman.dao.DocumentDAO8,com.libman.model.Document8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String requiredRole = "READER"; %>
<%@ include file="/WEB-INF/common/auth.jspf" %>
<%
    String keyword = request.getParameter("keyword");
    List<Document8> results = null;
    if (keyword != null) {
        keyword = keyword.trim();
        try (DocumentDAO8 dao = new DocumentDAO8()) {
            results = dao.searchByName(keyword);
        }
    }
    request.setAttribute("results", results);
    request.setAttribute("keyword", keyword);
%>
<c:set var="pageTitle" value="Tìm kiếm tài liệu" scope="request"/>
<%@ include file="/WEB-INF/common/header.jspf" %>
<h1>Tìm kiếm tài liệu</h1>
<form class="panel" method="get" action="ReaderDocumentSearch8.jsp">
  <label for="k" style="min-width:auto">Từ khoá:</label>
  <input type="text" id="k" name="keyword" value="<c:out value='${keyword}'/>" placeholder="Tên tài liệu" autofocus>
  <button type="submit">Tìm kiếm</button>
</form>

<c:if test="${results != null && empty results}">
  <div class="msg error">Không tìm thấy tài liệu phù hợp</div>
</c:if>
<div class="grid">
  <c:forEach var="d" items="${results}">
    <c:url var="detailUrl" value="/reader/DocumentDetail8.jsp">
      <c:param name="id" value="${d.id}"/><c:param name="keyword" value="${keyword}"/>
    </c:url>
    <a class="card" href="${detailUrl}">
      <div class="cover">Ảnh bìa
        <c:if test="${not empty d.coverPicture}"><img src="${pageContext.request.contextPath}/${d.coverPicture}" alt="" onerror="this.remove()"></c:if>
      </div>
      <div class="body">
        <strong><c:out value="${d.name}"/></strong>
        Năm xuất bản: <c:out value="${d.publicYear}"/><br>
        Tác giả: <c:out value="${d.author}"/><br>
        Hiện có: <c:out value="${d.quantity}"/>
      </div>
    </a>
  </c:forEach>
</div>
<div class="actions"><a class="btn secondary" href="ReaderMainUI8.jsp">Quay lại</a></div>
<%@ include file="/WEB-INF/common/footer.jspf" %>
