<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String requiredRole = "LIBRARIAN"; %>
<%@ include file="/WEB-INF/common/auth.jspf" %>
<c:set var="pageTitle" value="Trang chủ nhân viên thư viện" scope="request"/>
<%@ include file="/WEB-INF/common/header.jspf" %>
<h1>Trang chủ nhân viên thư viện</h1>
<div class="panel"><a class="btn" href="LendingDocument8.jsp">Cho mượn tài liệu</a></div>
<%@ include file="/WEB-INF/common/footer.jspf" %>
