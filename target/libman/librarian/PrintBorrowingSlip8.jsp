<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.Connection,java.sql.SQLException,java.time.LocalDate,java.util.*,com.libman.dao.*,com.libman.model.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% String requiredRole = "LIBRARIAN"; %>
<%@ include file="/WEB-INF/common/auth.jspf" %>
<%
    String error = null;
    boolean saved = false;
    BorrowingSlip8 slip = null;

    if ("1".equals(request.getParameter("saved")) && session.getAttribute("savedSlip") != null) {
        slip = (BorrowingSlip8) session.getAttribute("savedSlip");        // phiếu vừa lưu xong
        saved = true;
    } else {
        LibraryCard8 card = (LibraryCard8) session.getAttribute("lendCard");
        @SuppressWarnings("unchecked")
        List<DocumentForLend8> lendList = (List<DocumentForLend8>) session.getAttribute("lendList");
        if (card == null || lendList == null || lendList.isEmpty()) {
            response.sendRedirect("LendingDocument8.jsp");
            return;
        }
        // Dựng phiếu mượn + chi tiết (xem trước, chưa lưu)
        Librarian8 lib = new Librarian8();
        lib.setId(sessionUser.getId());
        lib.setFullName(sessionUser.getFullName());
        LocalDate today = LocalDate.now();
        slip = new BorrowingSlip8();
        slip.setBorrowDate(java.sql.Date.valueOf(today));
        slip.setReader(card.getReader());
        slip.setLibrarian(lib);
        for (DocumentForLend8 f : lendList) {
            BorrowingSlipDetail8 d = new BorrowingSlipDetail8();
            d.setBorrowingSlip(slip);
            d.setDocumentForLend(f);
            d.setReturnDeadline(java.sql.Date.valueOf(today.plusDays(f.getDocument().getBorrowDuration())));
            slip.getDetails().add(d);
        }

        if ("POST".equals(request.getMethod()) && "confirm".equals(request.getParameter("action"))) {
            // Lưu phiếu + chi tiết + cập nhật trạng thái/số lượng tài liệu trong cùng một transaction
            try (BorrowingSlipDetailDAO8 slipDao = new BorrowingSlipDetailDAO8()) {
                Connection c = slipDao.getConn();
                c.setAutoCommit(false);
                try {
                    slipDao.saveBorrowingSlipDetail(slip.getDetails());
                    new DocumentForLendDAO8(c).updateLendingStatusAndQuantity8(lendList);
                    c.commit();
                    session.setAttribute("savedSlip", slip);
                    session.removeAttribute("lendCard");
                    session.removeAttribute("lendOutstanding");
                    session.removeAttribute("lendList");
                    response.sendRedirect("PrintBorrowingSlip8.jsp?saved=1");
                    return;
                } catch (SQLException e) {
                    c.rollback();
                    slip.setId(0);
                    error = "Không thể lưu phiếu mượn: " + e.getMessage();
                }
            }
        }
    }
    request.setAttribute("slip", slip);
    request.setAttribute("saved", saved);
    request.setAttribute("error", error);
%>
<c:set var="pageTitle" value="Phiếu mượn tài liệu" scope="request"/>
<%@ include file="/WEB-INF/common/header.jspf" %>
<h1>Phiếu mượn tài liệu</h1>
<c:if test="${saved}"><div class="msg ok no-print">Lưu phiếu mượn thành công. Giao phiếu in cho bạn đọc.</div></c:if>
<c:if test="${not empty error}"><div class="msg error no-print"><c:out value="${error}"/></div></c:if>

<div class="panel">
  <div class="row"><label>Mã phiếu mượn:</label>
    <c:choose><c:when test="${saved}"><c:out value="${slip.id}"/></c:when><c:otherwise><em>(được cấp khi lưu)</em></c:otherwise></c:choose></div>
  <div class="row"><label>Ngày mượn:</label> <fmt:formatDate value="${slip.borrowDate}" pattern="dd/MM/yyyy"/></div>
  <div class="row"><label>Nhân viên phụ trách:</label> <c:out value="${slip.librarian.fullName}"/></div>
  <div class="row"><label>Tên bạn đọc:</label> <c:out value="${slip.reader.fullName}"/></div>
  <div class="row"><label>Mã bạn đọc:</label> <c:out value="${slip.reader.id}"/></div>
</div>

<table>
  <tr><th>Mã tài liệu</th><th>Tên tài liệu</th><th>Năm xuất bản</th><th>Tác giả</th><th>Tình trạng vật lý hiện tại</th><th>Hạn trả</th></tr>
  <c:forEach var="d" items="${slip.details}">
    <tr>
      <td><c:out value="${d.documentForLend.id}"/></td>
      <td><c:out value="${d.documentForLend.document.name}"/></td>
      <td><c:out value="${d.documentForLend.document.publicYear}"/></td>
      <td><c:out value="${d.documentForLend.document.author}"/></td>
      <td><c:out value="${d.documentForLend.physicalStatusText}"/></td>
      <td><fmt:formatDate value="${d.returnDeadline}" pattern="dd/MM/yyyy"/></td>
    </tr>
  </c:forEach>
</table>

<div class="actions no-print">
  <c:choose>
    <c:when test="${saved}">
      <a class="btn secondary" href="LendingDocument8.jsp">Lập phiếu mới</a>
      <button type="button" onclick="window.print()">In lại phiếu</button>
    </c:when>
    <c:otherwise>
      <a class="btn secondary" href="LendingDocument8.jsp">Quay lại</a>
      <form method="post" action="PrintBorrowingSlip8.jsp" style="margin:0">
        <input type="hidden" name="action" value="confirm">
        <button type="submit">In phiếu</button>
      </form>
    </c:otherwise>
  </c:choose>
</div>
<c:if test="${saved}"><script>window.addEventListener('load', function () { window.print(); });</script></c:if>
<%@ include file="/WEB-INF/common/footer.jspf" %>
