package com.example.caloriecalculator.dao;

import com.example.caloriecalculator.helper.image;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class imagedao {
    private final Connection connection;

    public imagedao(Connection connection) {
        this.connection = connection;
    }

    // 1. Save a new image entry
    public boolean saveImage(int userId, String entryDate, String imageData, String gptResponse) throws SQLException {
        String sql = "INSERT INTO image_queries (userId, base64Input, gptResponse, sentAt, imageDate) VALUES (?, ?, ?, NOW(), ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, imageData); // this is base64Input
            stmt.setString(3, gptResponse);
            stmt.setString(4, entryDate); // used as imageDate
            int rowsInserted = stmt.executeUpdate();
            return rowsInserted > 0;
        }
    }

    // 2. Get number of uploads for a user for a specific date
    public int getUploadCountForDate(int userId, String entryDate) throws SQLException {
        String sql = "SELECT COUNT(*) FROM image_queries WHERE userId = ? AND imageDate = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, entryDate);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
    /*
    // 3. Fetch all uploaded images for a specific user and date
    public ArrayList<image> getImagesByUserAndDate(int userId, String entryDate) throws SQLException {
        ArrayList<image> images = new ArrayList<>();
        String sql = "SELECT imageId, userId, entryDate, imageUrl, label, calories, mealType FROM image_queries WHERE userId = ? AND entryDate = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, entryDate);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    image img = new image(
                        rs.getInt("imageId"),
                        rs.getInt("userId"),
                        rs.getString("entryDate"),
                        rs.getString("imageUrl"),
                        rs.getString("label"),
                        rs.getInt("calories"),
                        rs.getString("mealType")
                    );
                    images.add(img);
                }
            }
        }
        return images;
    }
    */

    // 4. Delete an uploaded image using imageId
    public boolean deleteImageById(int imageId) throws SQLException {
        String sql = "DELETE FROM image_queries WHERE queryId = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, imageId);
            int rowsDeleted = stmt.executeUpdate();
            return rowsDeleted > 0;
        }
    }

    public static void storeImageQueryResult(Connection conn, int userId, String base64Input, String gptResponse) throws SQLException {
        String sql = "INSERT INTO image_queries (userId, base64Input, gptResponse, sentAt) VALUES (?, ?, ?, NOW())";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, base64Input); // rename imageName to base64Input in parameter name and usage
            stmt.setString(3, gptResponse); // Store raw response
            stmt.executeUpdate();
        }
    }
}