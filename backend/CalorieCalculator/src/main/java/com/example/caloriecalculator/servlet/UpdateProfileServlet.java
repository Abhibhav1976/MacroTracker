package com.example.caloriecalculator.servlet;

import com.example.caloriecalculator.helper.MySQLConnection;
import com.example.caloriecalculator.helper.user;
import com.example.caloriecalculator.dao.userdao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;

@WebServlet("/UpdateProfile")
public class UpdateProfileServlet extends HttpServlet {
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

        boolean isMobileRequest = "true".equals(request.getHeader("X-Mobile-App"));
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String password = (String) session.getAttribute("password");

        if (isMobileRequest) {
            // Handle mobile requests (JSON response)
            response.setContentType("application/json");
            try {
                // Parse request parameters
                int userId = Integer.parseInt(request.getParameter("userId"));
                Integer age = request.getParameter("age") != null ? Integer.parseInt(request.getParameter("age")) : null;
                Double currentWeight = request.getParameter("currentWeight") != null ? Double.parseDouble(request.getParameter("currentWeight")) : null;
                Double targetWeight = request.getParameter("targetWeight") != null ? Double.parseDouble(request.getParameter("targetWeight")) : null;
                Integer requiredCalories = request.getParameter("requiredCalories") != null ? Integer.parseInt(request.getParameter("requiredCalories")) : null;
                Double height = request.getParameter("height") != null ? Double.parseDouble(request.getParameter("height")) : null;
                String activityLevel = request.getParameter("activityLevel");
                String gender = request.getParameter("gender");
                String goalType = request.getParameter("goalType");
                String profilePicture = request.getParameter("profilePicture");

                // Find the user based on session data (username and password)
                user currentUser = userDao.findUser(username, password); // Uses stored session values
                if (currentUser != null) {
                    boolean isUpdated = userDao.updateUserDetails(userId, age, currentWeight, targetWeight,
                            requiredCalories, height, activityLevel,
                            gender, goalType, profilePicture);

                    if (isUpdated) {
                        // After updating, retrieve the updated user details using session data
                        currentUser = userDao.findUser(username, password);  // Re-fetch user to get updated details

                        if (currentUser != null) {
                            jsonResponse.put("success", true);
                            jsonResponse.put("message", "Profile updated successfully.");
                            jsonResponse.put("data", new JSONObject()
                                    .put("age", currentUser.getAge())
                                    .put("currentWeight", currentUser.getCurrentWeight())
                                    .put("targetWeight", currentUser.getTargetWeight())
                                    .put("requiredCalories", currentUser.getRequiredCalories())
                                    .put("height", currentUser.getHeight())
                                    .put("activityLevel", currentUser.getActivityLevel())
                                    .put("gender", currentUser.getGender())
                                    .put("goalType", currentUser.getGoalType())
                                    .put("profilePicture", currentUser.getProfilePicture()));
                        } else {
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "Failed to retrieve updated user details.");
                        }
                    } else {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "No fields were updated. Please check your input.");
                    }
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "User not found.");
                }
            } catch (Exception e) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Error: " + e.getMessage());
            }

            out.print(jsonResponse.toString());
            out.flush();
        } else {
            response.setContentType("text/html");
            response.getWriter().write("<html><body><h1>Non-mobile request, unable to display JSON.</h1></body></html>");
        }
    }

    @Override
    public void destroy() {
        super.destroy();
    }
}