<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" import="com.libman.dao.DocumentDAO8,com.libman.model.Document8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String requiredRole = "READER"; %>
<%@ include file="/WEB-INF/common/auth.jspf" %>
<%
    Document8 doc = null;
    try {
        int idDocument = Integer.parseInt(request.getParameter("id"));
        try (DocumentDAO8 dao = new DocumentDAO8()) {
            doc = dao.getDetail(idDocument);
        }
    } catch (NumberFormatException e) {
        doc = null;
    }
    if (doc == null) {
        response.sendError(404, "Không tìm thấy tài liệu");
        return;
    }
    request.setAttribute("doc", doc);
%>
<c:set var="pageTitle" value="Thông tin chi tiết" scope="request"/>
<%@ include file="/WEB-INF/common/header.jspf" %>
<h1>Thông tin chi tiết</h1>
<div class="panel detail">
  <div class="cover">Ảnh bìa
    <c:if test="${not empty doc.coverPicture}"><img src="${pageContext.request.contextPath}/${doc.coverPicture}" alt="" onerror="this.remove()"></c:if>
  </div>
  <div>
    <div class="row"><label>Tên tài liệu:</label> <c:out value="${doc.name}"/></div>
    <div class="row"><label>Mô tả:</label> <c:out value="${doc.description}"/></div>
    <div class="row"><label>Năm xuất bản:</label> <c:out value="${doc.publicYear}"/></div>
    <div class="row"><label>Tác giả:</label> <c:out value="${doc.author}"/></div>
    <div class="row"><label>Số lượng hiện có:</label> <c:out value="${doc.quantity}"/></div>
  </div>
</div>
<c:url var="backUrl" value="/reader/ReaderDocumentSearch8.jsp"><c:param name="keyword" value="${param.keyword}"/></c:url>
<div class="actions"><a class="btn secondary" href="${backUrl}">Quay lại</a></div>
<%@ include file="/WEB-INF/common/footer.jspf" %>
