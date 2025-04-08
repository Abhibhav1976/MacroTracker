package com.example.caloriecalculator.dao;

import com.example.caloriecalculator.helper.MySQLConnection;
import com.example.caloriecalculator.helper.user;
import org.mindrot.jbcrypt.BCrypt; // Add this library for password hashing

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class userdao {
    private final Connection connection;

    public userdao(Connection connection) {
        this.connection = connection;
    }

    // Find user by username and verify password
    public user findUser(String username, String password) throws SQLException {
        String query = "SELECT * FROM users WHERE username=?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, username);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    if (BCrypt.checkpw(password, hashedPassword)) { // Verify password
                        user user = new user();
                        user.setUser_id(rs.getInt("userId"));
                        user.setUsername(rs.getString("username"));
                        user.setPassword(hashedPassword); // Return the hashed password
                        user.setEmail(rs.getString("email"));

                        // Handle nullable fields using wrapper classes
                        user.setAge(rs.getObject("age", Integer.class)); // Will return null if age is null
                        user.setCurrentWeight(rs.getObject("currentWeight", Double.class)); // Will return null if currentWeight is null
                        user.setTargetWeight(rs.getObject("targetWeight", Double.class)); // Will return null if targetWeight is null
                        user.setRequiredCalories(rs.getObject("requiredCalories", Integer.class)); // Will return null if requiredCalories is null
                        user.setHeight(rs.getObject("height", Double.class)); // Will return null if height is null
                        user.setActivityLevel(rs.getString("activityLevel")); // String can handle null naturally
                        user.setGender(rs.getString("gender")); // String can handle null naturally
                        user.setGoalType(rs.getString("goalType")); // String can handle null naturally
                        user.setProfilePicture(rs.getString("profilePicture")); // String can handle null naturally
                        user.setMemberType(rs.getString("memberType"));
                        user.setStreak(rs.getObject("streak", Integer.class)); // Will return null if streak is null
                        user.setLastLoggedDate(rs.getString("last_logged_date")); // Assuming lastLoginDate is stored as a String
                        return user;
                    }
                }
            }
        }
        return null;
    }
    // Check if email is already registered
    public boolean isEmailRegistered(String email) throws SQLException {
        String query = "SELECT * FROM users WHERE email = ?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, email);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next(); // If a row exists, email is registered
            }
        }
    }

    // Create a new user with hashed password
    public boolean createUser(user newUser) throws SQLException {
        String query = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
        String hashedPassword = BCrypt.hashpw(newUser.getPassword(), BCrypt.gensalt()); // Hash the password
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, newUser.getUsername());
            statement.setString(2, newUser.getEmail());
            statement.setString(3, hashedPassword); // Store the hashed password
            //statement.setString(4, newUser.getDisplayName());
            return statement.executeUpdate() > 0; // Returns true if the insert was successful
        }
    }

    // Log macro entries
    public boolean logMacro(int userId, String entryDate, String mealType, int calories, BigDecimal carbs, BigDecimal protein, BigDecimal fat) throws SQLException {
        String query = "INSERT INTO macro_entries (userId, entryDate, mealType, calories, carbs, protein, fat) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            // Set the parameters for the prepared statement
            statement.setInt(1, userId);      // userId
            statement.setString(2, entryDate); // entryDate
            statement.setString(3, mealType);  // mealType
            statement.setInt(4, calories);     // calories
            statement.setBigDecimal(5, carbs); // carbs (BigDecimal for DECIMAL fields)
            statement.setBigDecimal(6, protein); // protein (BigDecimal for DECIMAL fields)
            statement.setBigDecimal(7, fat);    // fat (BigDecimal for DECIMAL fields)

            // Execute the update and check if any rows were affected
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        }
    }


    public boolean editMacro(int userId, String entryDate, String mealType, int calories, int carbs, int protein, int fat) throws SQLException {
        String query = "UPDATE macro_entries SET calories = ?, carbs = ?, protein = ?, fat = ? WHERE userId = ? AND entryDate = ? AND mealType = ?";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, calories); // calories
            statement.setInt(2, carbs); // carbs
            statement.setInt(3, protein); // protein
            statement.setInt(4, fat); // fat
            statement.setInt(5, userId); // userId
            statement.setString(6, entryDate); // entryDate
            statement.setString(7, mealType); // mealType

            int rowsAffected = statement.executeUpdate();

            return rowsAffected > 0;
        }
    }

    public ResultSet findMacro(int userId, String entryDate) throws SQLException {
        String query = "SELECT * FROM macro_entries WHERE userId = ? AND entryDate = ?";
        PreparedStatement statement = connection.prepareStatement(query);
        statement.setInt(1, userId);
        statement.setString(2, entryDate);

        return statement.executeQuery();
    }

    public boolean updateUserDetails(int userId, Integer age, Double currentWeight, Double targetWeight,
                                            Integer requiredCalories, Double height, String activityLevel,
                                            String gender, String goalType, String profilePicture) throws SQLException {
        StringBuilder queryBuilder = new StringBuilder("UPDATE users SET ");
        boolean firstField = true;

        // Append fields dynamically based on non-null parameters
        if (age != null) {
            queryBuilder.append("age = ?");
            firstField = false;
        }
        if (currentWeight != null) {
            queryBuilder.append(firstField ? "" : ", ").append("currentWeight = ?");
            firstField = false;
        }
        if (targetWeight != null) {
            queryBuilder.append(firstField ? "" : ", ").append("targetWeight = ?");
            firstField = false;
        }
        if (requiredCalories != null) {
            queryBuilder.append(firstField ? "" : ", ").append("requiredCalories = ?");
            firstField = false;
        }
        if (height != null) {
            queryBuilder.append(firstField ? "" : ", ").append("height = ?");
            firstField = false;
        }
        if (activityLevel != null) {
            queryBuilder.append(firstField ? "" : ", ").append("activityLevel = ?");
            firstField = false;
        }
        if (gender != null) {
            queryBuilder.append(firstField ? "" : ", ").append("gender = ?");
            firstField = false;
        }
        if (goalType != null) {
            queryBuilder.append(firstField ? "" : ", ").append("goalType = ?");
            firstField = false;
        }
        if (profilePicture != null) {
            queryBuilder.append(firstField ? "" : ", ").append("profilePicture = ?");
        }

        // Add the WHERE clause
        queryBuilder.append(" WHERE userId = ?");

        try (PreparedStatement statement = connection.prepareStatement(queryBuilder.toString())) {
            int parameterIndex = 1;

            // Set parameters dynamically
            if (age != null) statement.setInt(parameterIndex++, age);
            if (currentWeight != null) statement.setDouble(parameterIndex++, currentWeight);
            if (targetWeight != null) statement.setDouble(parameterIndex++, targetWeight);
            if (requiredCalories != null) statement.setInt(parameterIndex++, requiredCalories);
            if (height != null) statement.setDouble(parameterIndex++, height);
            if (activityLevel != null) statement.setString(parameterIndex++, activityLevel);
            if (gender != null) statement.setString(parameterIndex++, gender);
            if (goalType != null) statement.setString(parameterIndex++, goalType);
            if (profilePicture != null) statement.setString(parameterIndex++, profilePicture);

            // Set the userId for the WHERE clause
            statement.setInt(parameterIndex, userId);

            return statement.executeUpdate() > 0;
        }
    }

    public user getUserById(int userId) throws SQLException {
        String query = "SELECT streak, last_logged_date FROM users WHERE userId = ?";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    user u = new user();
                    u.setStreak(rs.getInt("streak"));
                    u.setLastLoggedDate(rs.getDate("last_logged_date") != null
                        ? String.valueOf(rs.getDate("last_logged_date").toLocalDate())
                        : null);
                    return u;
                }
            }
        }
        return null;
    }

    public void updateUserStreak(int userId, int newStreak, String lastLoggedDate) throws SQLException {
        String query = "UPDATE users SET streak = ?, last_logged_date = ? WHERE userId = ?";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setInt(1, newStreak);
            stmt.setString(2, lastLoggedDate);
            stmt.setInt(3, userId);
            stmt.executeUpdate();
        }
    }
}