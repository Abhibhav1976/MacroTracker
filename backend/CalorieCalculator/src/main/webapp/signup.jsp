<%--
  Created by IntelliJ IDEA.
  User: abhibhavrajsingh
  Date: 19/12/24
  Time: 12:40 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Sign Up</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body {
      font-family: 'Roboto', sans-serif;
      margin: 0;
      padding: 0;
      background-color: #1c1c1e;
      color: #f5f5f7;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 2rem;
    }
    .login-signup {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 80vh;
    }
    .form-container {
      background-color: #2c2c2e;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
      width: 100%;
      max-width: 400px;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .form-container:hover {
      transform: translateY(-10px);
      box-shadow: 0 8px 16px rgba(0, 0, 0, 0.5);
    }
    .form-container h2 {
      margin-bottom: 1.5rem;
      font-weight: 700;
      color: #f5f5f7;
    }
    .form-container input {
      width: 100%;
      padding: 0.75rem;
      margin-bottom: 1rem;
      border: 1px solid #3a3a3c;
      border-radius: 4px;
      background-color: #3a3a3c;
      color: #f5f5f7;
    }
    .form-container button {
      width: 100%;
      padding: 0.75rem;
      background-color: #0071e3;
      color: #fff;
      border: none;
      border-radius: 4px;
      font-size: 1rem;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }
    .form-container button:hover {
      background-color: #005bb5;
    }
  </style>
</head>
<body>
<div class="container">
  <div class="login-signup">
    <div class="form-container">
      <h2>Sign Up</h2>
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
    </div>
  </div>
</div>
</body>
</html>