<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*,java.time.LocalDate,com.libman.dao.*,com.libman.model.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String requiredRole = "LIBRARIAN"; %>
<%@ include file="/WEB-INF/common/auth.jspf" %>
<%
    final int MAX_BORROW = 13;
    String error = null;
    String action = request.getParameter("action");

    @SuppressWarnings("unchecked")
    List<DocumentForLend8> lendList = (List<DocumentForLend8>) session.getAttribute("lendList");
    if (lendList == null) { lendList = new ArrayList<>(); session.setAttribute("lendList", lendList); }

    if (action == null) {                                   // vào trang mới => bỏ phiếu đã in trước đó
        session.removeAttribute("savedSlip");
    } else if ("cancel".equals(action)) {                   // nút Quay lại
        session.removeAttribute("lendCard");
        session.removeAttribute("lendOutstanding");
        session.removeAttribute("lendList");
        response.sendRedirect("LibrarianMainUI8.jsp");
        return;
    } else if ("POST".equals(request.getMethod())) {
        if ("check".equals(action)) {                       // bước 4-6: kiểm tra thẻ bạn đọc
            session.removeAttribute("lendCard");
            session.removeAttribute("lendOutstanding");
            lendList.clear();
            String cardCode = request.getParameter("cardCode") == null ? "" : request.getParameter("cardCode").trim();
            try (LibraryCardDAO8 cardDao = new LibraryCardDAO8(); DocumentForLendDAO8 lendDao = new DocumentForLendDAO8()) {
                LibraryCard8 card = cardDao.searchByCode(cardCode);
                if (card == null) {
                    error = "Không tìm thấy thẻ bạn đọc có mã \"" + cardCode + "\"";
                } else if (card.validate(LocalDate.now()) != null) {
                    error = card.validate(LocalDate.now());
                } else {
                    session.setAttribute("lendCard", card);
                    session.setAttribute("lendOutstanding", lendDao.getBorrowedDocumentByLibraryCard8(card).size());
                }
            }
        } else if ("add".equals(action)) {                  // bước 8-9: thêm tài liệu
            LibraryCard8 card = (LibraryCard8) session.getAttribute("lendCard");
            if (card == null) {
                error = "Hãy kiểm tra thẻ bạn đọc trước khi thêm tài liệu";
            } else {
                String code = request.getParameter("documentCode") == null ? "" : request.getParameter("documentCode").trim();
                int outstanding = (Integer) session.getAttribute("lendOutstanding");
                try (DocumentForLendDAO8 dao = new DocumentForLendDAO8()) {
                    DocumentForLend8 f = dao.searchByCode8(code);
                    if (f == null) {
                        error = "Không tìm thấy tài liệu có mã \"" + code + "\"";
                    } else if ("TORN".equals(f.getPhysicalStatus())) {          // điều kiện 1: không rách
                        error = "Tài liệu có mã " + code + " bị rách/mất trang, không được phép mượn";
                    } else if (outstanding + lendList.size() + 1 > MAX_BORROW) { // điều kiện 2: tổng không quá 13
                        error = "Tổng số sách được mượn đã đạt giới hạn, xin hãy đem trả sách trước khi mượn thêm sách";
                    } else {
                        lendList.add(f);
                    }
                }
            }
        } else if ("remove".equals(action)) {
            final String removeId = request.getParameter("code");
            lendList.removeIf(x -> String.valueOf(x.getId()).equals(removeId));
        }
    }
    request.setAttribute("error", error);
%>
<c:set var="pageTitle" value="Phiếu mượn tài liệu" scope="request"/>
<%@ include file="/WEB-INF/common/header.jspf" %>
<h1>Phiếu mượn tài liệu</h1>
<c:if test="${not empty error}"><div class="msg error"><c:out value="${error}"/></div></c:if>

<div class="panel">
  <form method="post" action="LendingDocument8.jsp" class="row">
    <input type="hidden" name="action" value="check">
    <label for="cc">Mã thẻ bạn đọc:</label>
    <input type="text" id="cc" name="cardCode" value="<c:out value='${sessionScope.lendCard.id}'/>" autofocus>
    <button type="submit">Kiểm tra</button>
  </form>

  <c:if test="${not empty sessionScope.lendCard}">
    <div class="readerbox row">
      <div class="cover">Ảnh thẻ
        <c:if test="${not empty sessionScope.lendCard.reader.avatar}"><img src="${pageContext.request.contextPath}/${sessionScope.lendCard.reader.avatar}" alt="" onerror="this.remove()"></c:if>
      </div>
      <div>
        <strong><c:out value="${sessionScope.lendCard.reader.fullName}"/></strong><br>
        Mã sinh viên: <c:out value="${sessionScope.lendCard.reader.studentCode}"/><br>
        Số tài liệu đang mượn: <strong><c:out value="${sessionScope.lendOutstanding}"/></strong>
      </div>
    </div>
  </c:if>

  <form method="post" action="LendingDocument8.jsp">
    <input type="hidden" name="action" value="add">
    <label for="dc">Mã tài liệu:</label>
    <input type="text" id="dc" name="documentCode" <c:if test="${empty sessionScope.lendCard}">disabled</c:if>>
    <button type="submit" <c:if test="${empty sessionScope.lendCard}">disabled</c:if>>Thêm</button>
  </form>
</div>

<table>
  <tr><th>Mã tài liệu</th><th>Tên tài liệu</th><th>Năm xuất bản</th><th>Tác giả</th><th>Tình trạng vật lý hiện tại</th><th></th></tr>
  <c:forEach var="f" items="${sessionScope.lendList}">
    <tr>
      <td><c:out value="${f.id}"/></td>
      <td><c:out value="${f.document.name}"/></td>
      <td><c:out value="${f.document.publicYear}"/></td>
      <td><c:out value="${f.document.author}"/></td>
      <td><c:out value="${f.physicalStatusText}"/></td>
      <td>
        <form method="post" action="LendingDocument8.jsp" style="margin:0">
          <input type="hidden" name="action" value="remove">
          <input type="hidden" name="code" value="${f.id}">
          <button type="submit" class="danger">Xoá</button>
        </form>
      </td>
    </tr>
  </c:forEach>
  <c:if test="${empty sessionScope.lendList}"><tr><td colspan="6">Chưa có tài liệu nào trong phiếu.</td></tr></c:if>
</table>

<div class="actions">
  <a class="btn secondary" href="LendingDocument8.jsp?action=cancel">Quay lại</a>
  <form method="get" action="PrintBrorrowingSlip8.jsp" style="margin:0">
    <button type="submit" <c:if test="${empty sessionScope.lendList}">disabled</c:if>>In phiếu mượn</button>
  </form>
</div>
<%@ include file="/WEB-INF/common/footer.jspf" %>
