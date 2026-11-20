<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" import="com.libman.dao.UserDAO8,com.libman.model.User8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setCharacterEncoding("UTF-8");
    String error = null;
    String username = "";
    if ("POST".equals(request.getMethod())) {
        username = request.getParameter("username") == null ? "" : request.getParameter("username").trim();
        String password = request.getParameter("password") == null ? "" : request.getParameter("password");
        User8 user;
        try (UserDAO8 dao = new UserDAO8()) {
            user = dao.login(username, password);
        }
        if (user == null) {
            error = "Tên đăng nhập hoặc mật khẩu không đúng";
        } else {
            request.changeSessionId();                      // chống session fixation
            session.setAttribute("user", user);
            String target = "/reader/ReaderMainUI8.jsp";
            if ("LIBRARIAN".equals(user.getRole())) target = "/librarian/LibrarianMainUI8.jsp";
            else if ("MANAGER".equals(user.getRole())) target = "/manager/ManagerMainUI8.jsp";
            response.sendRedirect(request.getContextPath() + target);
            return;
        }
    }
    request.setAttribute("error", error);
    request.setAttribute("username", username);
%>
<c:set var="pageTitle" value="Đăng nhập" scope="request"/>
<%@ include file="/WEB-INF/common/header.jspf" %>
<h1>Đăng nhập</h1>
<c:if test="${not empty error}"><div class="msg error"><c:out value="${error}"/></div></c:if>
<form class="panel" method="post" action="Login.jsp">
  <div class="row"><label for="u">Tên đăng nhập</label><input type="text" id="u" name="username" value="<c:out value='${username}'/>" required autofocus></div>
  <div class="row"><label for="p">Mật khẩu</label><input type="password" id="p" name="password" required></div>
  <button type="submit">Đăng nhập</button>
</form>
<%@ include file="/WEB-INF/common/footer.jspf" %>
