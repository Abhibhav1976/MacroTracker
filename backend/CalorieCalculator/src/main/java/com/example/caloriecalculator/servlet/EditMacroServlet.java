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

@WebServlet("/EditMacro")
public class EditMacroServlet extends HttpServlet {
    private userdao userDao;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            Connection conn = MySQLConnection.getConnection();
            userDao = new userdao(conn);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String entryDate = request.getParameter("entryDate");
        String mealType = request.getParameter("mealType");
        int calories = Integer.parseInt(request.getParameter("calories"));
        int carbs = Integer.parseInt(request.getParameter("carbs"));
        int protein = Integer.parseInt(request.getParameter("protein"));
        int fat = Integer.parseInt(request.getParameter("fat"));

        HttpSession session = request.getSession();
        user currentUser = (user) session.getAttribute("user");

        boolean isMobileRequest = "true".equals(request.getHeader("X-Mobile-App"));
        response.setCharacterEncoding("UTF-8");

        if(isMobileRequest) {
            response.setContentType("application/json");
            try (PrintWriter out = response.getWriter()) {
                boolean editSuccess = userDao.editMacro(Integer.parseInt(userId), entryDate, mealType, calories, carbs, protein, fat);
                JSONObject jsonResponse = new JSONObject();

                if(editSuccess){
                    jsonResponse.put("success", true);
                    jsonResponse.put("message", "Macro edited successfully");
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Macro edited failed");
                }
                out.print(jsonResponse.toString());
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        } else {
            try {
                boolean editSuccess = userDao.editMacro(Integer.parseInt(userId), entryDate, mealType, calories, carbs, protein, fat);
                if(editSuccess){
                    response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/error.jsp");
                }
            } catch (Exception e){
                response.sendRedirect(request.getContextPath() + "/error.jsp");
            }
        }
    }
}
