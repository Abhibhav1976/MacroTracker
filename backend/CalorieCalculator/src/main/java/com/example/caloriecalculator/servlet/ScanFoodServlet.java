package com.example.caloriecalculator.servlet;

import com.example.caloriecalculator.dao.FoodDao;
import com.example.caloriecalculator.helper.MySQLConnection;
import com.example.caloriecalculator.helper.ScannedFood;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/scanFood")
public class ScanFoodServlet extends HttpServlet {
    private FoodDao foodDao;
    private static final Logger LOGGER = Logger.getLogger(ScanFoodServlet.class.getName());

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            Connection conn = MySQLConnection.getConnection();
            foodDao = new FoodDao(conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to initialize FoodDao", e);
            throw new ServletException("Unable to initialize FoodDao", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        // Check if the request is from a mobile app
        boolean isMobileRequest = "true".equals(request.getHeader("X-Mobile-App"));

        try (PrintWriter out = response.getWriter()) {
            // Parse common input parameters
            String barcode = request.getParameter("barcode");
            String userId = request.getParameter("userId");

            if (barcode == null || userId == null || barcode.isEmpty() || userId.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                if (isMobileRequest) {
                    out.print(new JSONObject()
                            .put("success", false)
                            .put("message", "Barcode and User ID are required.").toString());
                } else {
                    response.sendRedirect("error.jsp?message=Barcode+and+User+ID+are+required");
                }
                return;
            }

            try {
                ScannedFood existingFood = foodDao.getScannedFood(userId, barcode);

                if (existingFood != null) {
                    // If barcode exists, return food details
                    if (isMobileRequest) {
                        JSONObject jsonResponse = new JSONObject()
                                .put("success", true)
                                .put("message", "Food already scanned.")
                                .put("foodName", existingFood.getFoodName())
                                .put("calories", existingFood.getCalories())
                                .put("carbs", existingFood.getCarbs())
                                .put("protein", existingFood.getProtein())
                                .put("fat", existingFood.getFat())
                                .put("scannedDate", existingFood.getScannedDate().toString());
                        out.print(jsonResponse.toString());
                    } else {
                        response.sendRedirect("foodDetails.jsp?barcode=" + barcode);
                    }
                } else {
                    // If barcode does not exist, check if additional parameters are provided
                    String foodName = request.getParameter("foodName");
                    String caloriesParam = request.getParameter("calories");
                    String carbsParam = request.getParameter("carbs");
                    String proteinParam = request.getParameter("protein");
                    String fatParam = request.getParameter("fat");

                    if (foodName == null || caloriesParam == null || carbsParam == null ||
                            proteinParam == null || fatParam == null ||
                            foodName.isEmpty() || caloriesParam.isEmpty() ||
                            carbsParam.isEmpty() || proteinParam.isEmpty() || fatParam.isEmpty()) {
                        // If additional data is missing
                        if (isMobileRequest) {
                            out.print(new JSONObject()
                                    .put("success", false)
                                    .put("message", "Barcode does not exist. Full food details required.").toString());
                        } else {
                            response.sendRedirect("error.jsp?message=Barcode+does+not+exist");
                        }
                    } else {
                        // Parse additional parameters and save the food entry
                        int calories = Integer.parseInt(caloriesParam);
                        BigDecimal carbs = new BigDecimal(carbsParam);
                        BigDecimal protein = new BigDecimal(proteinParam);
                        BigDecimal fat = new BigDecimal(fatParam);

                        boolean success = foodDao.saveScannedFood(userId, barcode, foodName, calories, carbs, protein, fat);

                        if (success) {
                            if (isMobileRequest) {
                                out.print(new JSONObject()
                                        .put("success", true)
                                        .put("message", "Food saved successfully.")
                                        .put("foodName", foodName).toString());
                            } else {
                                response.sendRedirect("foodSuccess.jsp?message=Food+saved+successfully");
                            }
                        } else {
                            if (isMobileRequest) {
                                out.print(new JSONObject()
                                        .put("success", false)
                                        .put("message", "Failed to save food.").toString());
                            } else {
                                response.sendRedirect("error.jsp?message=Failed+to+save+food");
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error processing scanned food", e);
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                if (isMobileRequest) {
                    out.print(new JSONObject()
                            .put("success", false)
                            .put("message", "Server error while processing the request.").toString());
                } else {
                    response.sendRedirect("error.jsp?message=Server+error");
                }
            }
        }
    }


    @Override
    public void destroy() {
        super.destroy();
    }
}