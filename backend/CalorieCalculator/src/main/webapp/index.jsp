<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>JSP - Hello World</title>
</head>
<body>
<h1><%= "Hello World!" %>
</h1>
<br/>
<a href="hello-servlet">Hello Servlet</a>
<h2>Login</h2>
<form action="${pageContext.request.contextPath}/login" method="post">
    Username: <input type="text" name="username" required><br>
    Password: <input type="password" name="password" required><br>
    <button type="submit" value="Login"> Login </button>
</form>
<c:if test="${not empty param.error}">
    <p style="color: red;">${param.error}</p>
</c:if>
<form action="${pageContext.request.contextPath}/signup.jsp" method="get">
    <button type="submit">Sign Up</button>
</form>
<form action="${pageContext.request.contextPath}/signup" method="post">
    <!-- Signup fields like username, password, email, etc. -->
    Username: <input type="text" name="username" required><br>
    Password: <input type="password" name="password" required><br>
    Email: <input type="email" name="email" required><br>
    <button type="submit">Sign Up</button>
</form>
<c:if test="${not empty param.error}">
    <p style="color: red;">${param.error}</p>
</c:if>
<form action="${pageContext.request.contextPath}/login.jsp" method="get">
    <button type="submit"> Login </button>
</form>
</body>
</html>