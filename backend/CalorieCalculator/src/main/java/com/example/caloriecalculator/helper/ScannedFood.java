package com.example.caloriecalculator.helper;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ScannedFood {
    private int foodId;
    private String userId;
    private String barcode;
    private String foodName;
    private int calories;
    private BigDecimal carbs;
    private BigDecimal protein;
    private BigDecimal fat;
    private Timestamp scannedDate;

    // Constructor
    public ScannedFood(int foodId, String userId, String barcode, String foodName, int calories, BigDecimal carbs, BigDecimal protein, BigDecimal fat, Timestamp scannedDate) {
        this.foodId = foodId;
        this.userId = userId;
        this.barcode = barcode;
        this.foodName = foodName;
        this.calories = calories;
        this.carbs = carbs;
        this.protein = protein;
        this.fat = fat;
        this.scannedDate = scannedDate;
    }

    // Getters
    public int getFoodId() {
        return foodId;
    }

    public String getUserId() {
        return userId;
    }

    public String getBarcode() {
        return barcode;
    }

    public String getFoodName() {
        return foodName;
    }

    public int getCalories() {
        return calories;
    }

    public BigDecimal getCarbs() {
        return carbs;
    }

    public BigDecimal getProtein() {
        return protein;
    }

    public BigDecimal getFat() {
        return fat;
    }

    public Timestamp getScannedDate() {
        return scannedDate;
    }

    // Setters
    public void setFoodId(int foodId) {
        this.foodId = foodId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public void setFoodName(String foodName) {
        this.foodName = foodName;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }

    public void setCarbs(BigDecimal carbs) {
        this.carbs = carbs;
    }

    public void setProtein(BigDecimal protein) {
        this.protein = protein;
    }

    public void setFat(BigDecimal fat) {
        this.fat = fat;
    }

    public void setScannedDate(Timestamp scannedDate) {
        this.scannedDate = scannedDate;
    }

    // ToString Method
    @Override
    public String toString() {
        return "ScannedFood{" +
                "foodId=" + foodId +
                ", userId='" + userId + '\'' +
                ", barcode='" + barcode + '\'' +
                ", foodName='" + foodName + '\'' +
                ", calories=" + calories +
                ", carbs=" + carbs +
                ", protein=" + protein +
                ", fat=" + fat +
                ", scannedDate=" + scannedDate +
                '}';
    }
}