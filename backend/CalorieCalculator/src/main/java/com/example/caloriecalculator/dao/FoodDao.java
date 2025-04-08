package com.example.caloriecalculator.dao;

import com.example.caloriecalculator.helper.ScannedFood;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class FoodDao {
    private Connection conn;

    public FoodDao(Connection conn) {
        this.conn = conn;
    }

    public ScannedFood getScannedFood(String userId, String barcode) throws SQLException {
        String query = "SELECT * FROM scanned_foods WHERE userId = ? AND barcode = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, userId);
            stmt.setString(2, barcode);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new ScannedFood(
                            rs.getInt("foodId"),
                            rs.getString("userId"),
                            rs.getString("barcode"),
                            rs.getString("foodName"),
                            rs.getInt("calories"),
                            rs.getBigDecimal("carbs"),
                            rs.getBigDecimal("protein"),
                            rs.getBigDecimal("fat"),
                            rs.getTimestamp("scannedDate")
                    );
                }
            }
        }
        return null;
    }
    public boolean saveScannedFood(String userId, String barcode, String foodName, int calories, BigDecimal carbs, BigDecimal protein, BigDecimal fat) throws SQLException {
        // Check if the food already exists
        if (getScannedFood(userId, barcode) != null) {
            return false; // Food already exists
        }

        // Insert new food into the database
        String query = "INSERT INTO scanned_foods (userId, barcode, foodName, calories, carbs, protein, fat) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, userId);
            stmt.setString(2, barcode);
            stmt.setString(3, foodName);
            stmt.setInt(4, calories);
            stmt.setBigDecimal(5, carbs);
            stmt.setBigDecimal(6, protein);
            stmt.setBigDecimal(7, fat);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public boolean checkDuplicateEntry(String userId, String barcode) throws SQLException {
        String query = "SELECT 1 FROM scanned_foods WHERE userId = ? AND barcode = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, userId);
            stmt.setString(2, barcode);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next(); // Returns true if a record exists
            }
        }
    }
}