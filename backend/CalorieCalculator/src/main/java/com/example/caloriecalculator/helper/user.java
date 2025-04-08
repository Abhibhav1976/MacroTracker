package com.example.caloriecalculator.helper;

public class user {
    private int user_id;
    private String username;
    private String password;
    private String displayName;
    private String email;
    private Integer age; // Nullable
    private Double currentWeight; // Nullable
    private Double targetWeight; // Nullable
    private Integer requiredCalories; // Nullable
    private Double height; // Nullable
    private String activityLevel;
    private String gender;
    private String goalType;
    private String profilePicture;
    private String memberType;
    private int streak; // New field
    private String lastLoggedDate; // New field

    // Getters and Setters
    public int getUser_id() { return user_id; }
    public void setUser_id(int user_id) { this.user_id = user_id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }

    public Double getCurrentWeight() { return currentWeight; }
    public void setCurrentWeight(Double currentWeight) { this.currentWeight = currentWeight; }

    public Double getTargetWeight() { return targetWeight; }
    public void setTargetWeight(Double targetWeight) { this.targetWeight = targetWeight; }

    public Integer getRequiredCalories() { return requiredCalories; }
    public void setRequiredCalories(Integer requiredCalories) { this.requiredCalories = requiredCalories; }

    public Double getHeight() { return height; }
    public void setHeight(Double height) { this.height = height; }

    public String getActivityLevel() { return activityLevel; }
    public void setActivityLevel(String activityLevel) { this.activityLevel = activityLevel; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getGoalType() { return goalType; }
    public void setGoalType(String goalType) { this.goalType = goalType; }

    public String getProfilePicture() { return profilePicture; }
    public void setProfilePicture(String profilePicture) { this.profilePicture = profilePicture; }

    public String getMemberType() { return memberType; }
    public void setMemberType(String memberType) { this.memberType = memberType; }

    public int getStreak() { return streak; } // New getter
    public void setStreak(int streak) { this.streak = streak; } // New setter

    public String getLastLoggedDate() { return lastLoggedDate; } // New getter
    public void setLastLoggedDate(String lastLoggedDate) { this.lastLoggedDate = lastLoggedDate; } // New setter
}
