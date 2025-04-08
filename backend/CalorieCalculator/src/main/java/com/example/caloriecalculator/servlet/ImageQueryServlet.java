package com.example.caloriecalculator.servlet;

import com.example.caloriecalculator.dao.imagedao;
import com.example.caloriecalculator.helper.MySQLConnection;
import com.example.caloriecalculator.helper.OpenAIHelper;

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
import java.io.BufferedReader;
import java.util.Base64;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

@WebServlet("/ImageQuery")
public class ImageQueryServlet extends HttpServlet {
    private imagedao imageDao;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            Connection connection = MySQLConnection.getConnection();
            imageDao = new imagedao(connection);
        } catch (SQLException e) {
            throw new ServletException("Unable to initialize imageDao", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            // Parse JSON input from request
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            JSONObject inputJson = new JSONObject(sb.toString());

            int userId = inputJson.getInt("userId");
            String entryDate = inputJson.getString("entryDate");
            String base64Image = inputJson.getString("base64Image");
            byte[] imageBytes = Base64.getDecoder().decode(base64Image);
            Path tempImagePath = Files.createTempFile("upload_", ".jpg");
            Files.write(tempImagePath, imageBytes);

            // Step 1: Check upload allowance
            int count = imageDao.getUploadCountForDate(userId, entryDate);
            if (count >= 4) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                JSONObject errorJson = new JSONObject();
                errorJson.put("error", "Daily upload limit reached.");
                out.print(errorJson.toString());
                Files.deleteIfExists(tempImagePath); // Delete temp file
                return;
            }

            String prompt = "You are a calorie and nutrition recognition model. Analyze this image and provide the estimated calories, protein, carbs, and fat content in a JSON format.";
            String gptResponse;

            try {
                gptResponse = OpenAIHelper.callModelWithImage(tempImagePath.toString(), prompt);
                System.out.println("GPT raw response: " + gptResponse);

                // Parse the model response as JSON
                JSONObject modelJson = new JSONObject(gptResponse);
                String predictedLabel = modelJson.getString("label");
                int predictedCalories = modelJson.getInt("calories");
                int protein = modelJson.getInt("protein");
                int carbs = modelJson.getInt("carbs");
                int fat = modelJson.getInt("fat");

                // Step 3: Save final result to DB (only one write)
                imageDao.saveImage(userId, entryDate, base64Image, gptResponse);

                // Step 4: Return result to client
                JSONObject result = new JSONObject();
                result.put("label", predictedLabel);
                result.put("calories", predictedCalories);
                result.put("protein", protein);
                result.put("carbs", carbs);
                result.put("fat", fat);
                out.print(result.toString());

            } catch (Exception modelError) {
                String predictedLabel = "error";
                int predictedCalories = -1;
                int protein = 0;
                int carbs = 0;
                int fat = 0;
                gptResponse = modelError.getMessage(); // Store error message
                modelError.printStackTrace();
                System.out.println("GPT error response: " + gptResponse);

                // Save error response to DB
                imageDao.saveImage(userId, entryDate, base64Image, gptResponse);

                // Return error response to client
                JSONObject result = new JSONObject();
                result.put("label", predictedLabel);
                result.put("calories", predictedCalories);
                result.put("protein", protein);
                result.put("carbs", carbs);
                result.put("fat", fat);
                out.print(result.toString());
            } finally {
                // Delete the temporary file
                Files.deleteIfExists(tempImagePath);
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject errorJson = new JSONObject();
            errorJson.put("error", "An error occurred: " + e.getMessage());
            out.print(errorJson.toString());
        }
    }
}
