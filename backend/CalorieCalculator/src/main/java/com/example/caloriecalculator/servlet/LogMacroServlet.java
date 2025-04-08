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
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;

@WebServlet("/LogMacro")
public class LogMacroServlet extends HttpServlet {
    private userdao userDao;

    @Override
    public void init() throws ServletException {
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
        StringBuilder debugInfo = new StringBuilder();

        // Get parameters from request
        String userId = request.getParameter("userId");
        String entryDate = request.getParameter("entryDate"); // Expected format: "YYYY-MM-DD"
        String mealType = request.getParameter("mealType");
        int calories = Integer.parseInt(request.getParameter("calories"));
        BigDecimal carbs = new BigDecimal(request.getParameter("carbs"));
        BigDecimal protein = new BigDecimal(request.getParameter("protein"));
        BigDecimal fat = new BigDecimal(request.getParameter("fat"));

        boolean isMobileRequest = "true".equals(request.getHeader("X-Mobile-App"));
        response.setCharacterEncoding("UTF-8");

        try {
            user userData = userDao.getUserById(Integer.parseInt(userId));
            LocalDate lastLoggedDate = LocalDate.parse(userData.getLastLoggedDate());

            Integer currentStreak = userData.getStreak();
            if (currentStreak == null) {
                currentStreak = 0; // Default to 0 if the streak is null
            }

            // Streak update logic
            int updatedStreak = currentStreak;
            if (lastLoggedDate != null) {
                if (LocalDate.parse(entryDate).isEqual(lastLoggedDate)) {
                } else if (LocalDate.parse(entryDate).minusDays(1).isEqual(lastLoggedDate)) {
                    updatedStreak = currentStreak + 1;
                } else {
                    updatedStreak = 1;
                }
            } else {
                updatedStreak = 1;
            }

            // Log the macro entry
            boolean logSuccess = userDao.logMacro(Integer.parseInt(userId), entryDate, mealType, calories, carbs, protein, fat);

            if (logSuccess) {
                userDao.updateUserStreak(Integer.parseInt(userId), updatedStreak, entryDate);
            }

            // Send JSON response with debug info
            response.setContentType("application/json");
            try (PrintWriter out = response.getWriter()) {
                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("success", logSuccess);
                jsonResponse.put("message", logSuccess ? "Macro logged successfully!" : "Failed to log macros.");
                jsonResponse.put("debug", debugInfo.toString());
                out.print(jsonResponse.toString());
            }

        } catch (SQLException e) {
            e.printStackTrace(); // Print the full stack trace for debugging

            response.setContentType("application/json");
            try (PrintWriter out = response.getWriter()) {
                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Database error while logging macro");
                jsonResponse.put("debug", debugInfo.toString());
                out.print(jsonResponse.toString());
            }
        }
    }
}