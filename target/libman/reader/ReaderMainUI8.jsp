<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String requiredRole = "READER"; %>
<%@ include file="/WEB-INF/common/auth.jspf" %>
<c:set var="pageTitle" value="Trang chủ bạn đọc" scope="request"/>
<%@ include file="/WEB-INF/common/header.jspf" %>
<h1>Trang chủ bạn đọc</h1>
<div class="panel"><a class="btn" href="ReaderDocumentSearch8.jsp">Tìm kiếm tài liệu</a></div>
<%@ include file="/WEB-INF/common/footer.jspf" %>
