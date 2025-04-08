package com.example.caloriecalculator.servlet;

import com.example.caloriecalculator.helper.MySQLConnection;
import com.example.caloriecalculator.helper.user;
import com.example.caloriecalculator.dao.userdao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import org.json.JSONObject;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private userdao userDao;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            Connection conn = MySQLConnection.getConnection();
            userDao = new userdao(conn);
        } catch (SQLException e) {
            throw new ServletException("Unable to initialize userDao", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        boolean isMobileRequest = "true".equals(request.getHeader("X-Mobile-App"));
        response.setCharacterEncoding("UTF-8");

        if (isMobileRequest) {
            // JSON Response for Mobile App
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try (PrintWriter out = response.getWriter()) {
                user currentUser = userDao.findUser(username, password);

                if (currentUser != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("currentUser", currentUser);
                    session.setAttribute("userId", currentUser.getUser_id());
                    session.setAttribute("username", currentUser.getUsername());  // Store username
                    session.setAttribute("password", password);  // Store password

                    JSONObject jsonResponse = new JSONObject();
                    jsonResponse.put("success", true);
                    jsonResponse.put("userId", currentUser.getUser_id());
                    jsonResponse.put("username", currentUser.getUsername());
                    jsonResponse.put("password", currentUser.getPassword());
                    jsonResponse.put("displayName", currentUser.getDisplayName());
                    jsonResponse.put("email", currentUser.getEmail());
                    jsonResponse.put("age", currentUser.getAge());
                    jsonResponse.put("currentWeight", currentUser.getCurrentWeight());
                    jsonResponse.put("targetWeight", currentUser.getTargetWeight());
                    jsonResponse.put("requiredCalories", currentUser.getRequiredCalories());
                    jsonResponse.put("height", currentUser.getHeight());
                    jsonResponse.put("activityLevel", currentUser.getActivityLevel());
                    jsonResponse.put("gender", currentUser.getGender());
                    jsonResponse.put("goalType", currentUser.getGoalType());
                    jsonResponse.put("profilePicture", currentUser.getProfilePicture());
                    jsonResponse.put("memberType", currentUser.getMemberType());
                    jsonResponse.put("streak", currentUser.getStreak());
                    jsonResponse.put("last_logged_date", currentUser.getLastLoggedDate());
                    out.print(jsonResponse.toString());
                } else {
                    JSONObject jsonResponse = new JSONObject();
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Invalid username or password");
                    out.print(jsonResponse.toString());
                }
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        } else {
            try {
                user currentUser = userDao.findUser(username, password);
                // Web App Response
                if (currentUser != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("currentUser", currentUser);
                    session.setAttribute("userId", currentUser.getUser_id());
                    session.setAttribute("username", currentUser.getUsername());  // Store username
                    session.setAttribute("password", password);  // Store password
                    response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                } else {
                    // Redirect only for web requests
                    response.sendRedirect("login.jsp");
                }
            } catch (SQLException e) {
                throw new ServletException("Unable to initialize userDao", e);
            }
        }
    }

    @Override
    public void destroy() {
        super.destroy();
    }
}