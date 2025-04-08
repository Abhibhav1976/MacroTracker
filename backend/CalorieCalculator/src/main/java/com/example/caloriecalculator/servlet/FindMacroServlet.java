package com.example.caloriecalculator.servlet;

import com.example.caloriecalculator.dao.userdao;
import com.example.caloriecalculator.helper.MySQLConnection;
import com.example.caloriecalculator.helper.user;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;

@WebServlet("/FindMacro")
public class FindMacroServlet extends HttpServlet {
    private userdao userDao;
    private static final Logger logger = Logger.getLogger(FindMacroServlet.class.getName());

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
        // Get parameters from request
        String userId = request.getParameter("userId");
        String entryDate = request.getParameter("entryDate");
        //String mealType = request.getParameter("mealType");

        boolean isMobileRequest = "true".equals(request.getHeader("X-Mobile-App"));
        response.setCharacterEncoding("UTF-8");

        if (isMobileRequest) {
            // Handle mobile requests (JSON response)
            response.setContentType("application/json");
            try (PrintWriter out = response.getWriter()) {
                // Call findMacro from userDao to fetch the data
                ResultSet rs = userDao.findMacro(Integer.parseInt(userId), entryDate);

                // Convert ResultSet to JSON Array
                JSONArray jsonResponse = new JSONArray();
                while (rs.next()) {
                    JSONObject macroData = new JSONObject();
                    macroData.put("userId", rs.getInt("userId"));
                    macroData.put("entryDate", rs.getString("entryDate"));
                    macroData.put("mealType", rs.getString("mealType"));
                    macroData.put("calories", rs.getInt("calories"));
                    macroData.put("carbs", rs.getInt("carbs"));
                    macroData.put("protein", rs.getInt("protein"));
                    macroData.put("fat", rs.getInt("fat"));

                    jsonResponse.put(macroData);
                }

                // Log the JSON response before sending it
            //    logger.info("JSON response: " + jsonResponse.toString());

                out.print(jsonResponse.toString());
            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Error retrieving data\"}");
            }
        } else {
            // Handle non-mobile requests (could be a redirect, depending on your use case)
            response.setContentType("text/html");
            response.getWriter().write("<html><body><h1>Non-mobile request, unable to display JSON.</h1></body></html>");
        }
    }
}