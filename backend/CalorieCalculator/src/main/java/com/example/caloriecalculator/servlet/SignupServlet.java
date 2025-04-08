package com.example.caloriecalculator.servlet;

import com.example.caloriecalculator.helper.MySQLConnection;
import com.example.caloriecalculator.dao.userdao;
import com.example.caloriecalculator.helper.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String displayName = request.getParameter("displayName");

        boolean isMobileRequest = "true".equals(request.getHeader("X-Mobile-App"));
        response.setCharacterEncoding("UTF-8");

        try (Connection conn = MySQLConnection.getConnection()) {
            userdao userDao = new userdao(conn);

            // Check if email already exists
            if (userDao.isEmailRegistered(email)) {
                if (isMobileRequest) {
                    response.setContentType("application/json");
                    try (PrintWriter out = response.getWriter()) {
                        JSONObject obj = new JSONObject();
                        obj.put("status", "error");
                        obj.put("message", "Email already registered!");
                        out.print(obj);
                    }
                } else {
                    response.setContentType("text/plain");
                    response.getWriter().write("Email already registered!");
                }
                return;
            }

            // Don't hash the password, store it as it is
            user newUser = new user();
            newUser.setUsername(username);
            newUser.setDisplayName(displayName);
            newUser.setEmail(email);
            newUser.setPassword(password); // Directly storing the password without hashing
            boolean success = userDao.createUser(newUser);

            if (success) {
                if (isMobileRequest) {
                    response.setContentType("application/json");
                    try (PrintWriter out = response.getWriter()) {
                        JSONObject obj = new JSONObject();
                        obj.put("success", true);
                        obj.put("message", "Signup successful!");
                        out.print(obj);
                    }
                } else {
                    response.setContentType("text/plain");
                    response.getWriter().write("Signup successful!");
                }
            } else {
                if (isMobileRequest) {
                    response.setContentType("application/json");
                    try (PrintWriter out = response.getWriter()) {
                        JSONObject obj = new JSONObject();
                        obj.put("success", false);
                        obj.put("message", "Error occurred during signup.");
                        out.print(obj);
                    }
                } else {
                    response.setContentType("text/plain");
                    response.getWriter().write("Error occurred during signup.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (isMobileRequest) {
                response.setContentType("application/json");
                try (PrintWriter out = response.getWriter()) {
                    JSONObject obj = new JSONObject();
                    obj.put("status", "error");
                    obj.put("message", "Error occurred during signup.");
                    out.print(obj);
                }
            } else {
                response.setContentType("text/plain");
                response.getWriter().write("Error occurred during signup.");
            }
        }
    }
}
