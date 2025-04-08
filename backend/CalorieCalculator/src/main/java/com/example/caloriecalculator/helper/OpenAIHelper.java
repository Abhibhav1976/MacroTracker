package com.example.caloriecalculator.helper;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import org.json.JSONArray;
import org.json.JSONObject;
import java.nio.file.Files;

public class OpenAIHelper {
    private static final String OPENAI_API_KEY = "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";
    private static final String OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";

    /**
     * Calls GPT-4o API with an image and a prompt.
     *
     * @param imagePath Path to raw image file (JPEG/PNG).
     * @param prompt    Text prompt for GPT-4o.
     * @return Response from GPT-4o.
     * @throws IOException If an I/O error occurs.
     */
    public static String callModelWithImage(String imagePath, String prompt) throws IOException {
        // Validate API key
        if (OPENAI_API_KEY == null || OPENAI_API_KEY.isEmpty()) {
            throw new IOException("OpenAI API key is not set or invalid.");
        }

        // Validate image file
        File imageFile = new File(imagePath);
        if (!imageFile.exists() || !imageFile.isFile()) {
            throw new IOException("Image file does not exist or is invalid: " + imagePath);
        }

        // Open connection to GPT-4o API
        URL url = new URL(OPENAI_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        try {
            // Set request headers
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + OPENAI_API_KEY);
            conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=boundary123");
            conn.setDoOutput(true);

            // Read the image file into a byte array
            byte[] imageBytes = Files.readAllBytes(imageFile.toPath());

            // Build multipart request body
            String boundary = "boundary123";
            ByteArrayOutputStream bodyStream = new ByteArrayOutputStream();
            PrintWriter writer = new PrintWriter(new OutputStreamWriter(bodyStream, "UTF-8"), true);

            // Add JSON part (prompt)
            writer.append("--").append(boundary).append("\r\n");
            writer.append("Content-Disposition: form-data; name=\"messages\"\r\n");
            writer.append("Content-Type: application/json; charset=UTF-8\r\n\r\n");

            JSONObject messageJson = new JSONObject();
            messageJson.put("role", "user");
            messageJson.put("content", prompt);

            JSONArray messagesArray = new JSONArray();
            messagesArray.put(messageJson);

            JSONObject requestBodyJson = new JSONObject();
            requestBodyJson.put("model", "gpt-4o");
            requestBodyJson.put("messages", messagesArray);

            writer.append(requestBodyJson.toString()).append("\r\n");

            // Add image part
            writer.append("--").append(boundary).append("\r\n");
            writer.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n");
            writer.append("Content-Type: image/jpeg\r\n\r\n").flush();

            bodyStream.write(imageBytes);

            writer.append("\r\n").flush();

            // End boundary
            writer.append("--").append(boundary).append("--\r\n").flush();

            // Send request
            try (OutputStream os = conn.getOutputStream()) {
                os.write(bodyStream.toByteArray());
                os.flush();
            }

            // Read response
            int responseCode = conn.getResponseCode();

            if (responseCode != 200) {
                InputStream errorStream = conn.getErrorStream();
                String errorMessage = errorStream != null ? new String(errorStream.readAllBytes()) : "No error stream available";
                throw new IOException("API responded with code " + responseCode + ": " + errorMessage);
            }

            StringBuilder responseText = new StringBuilder();

            try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    responseText.append(responseLine.trim());
                }
            }

            // Parse response JSON
            JSONObject jsonResponse = new JSONObject(responseText.toString());

            if (!jsonResponse.has("choices")) {
                throw new IOException("Invalid response format: 'choices' field missing.");
            }

            return jsonResponse.getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content");

        } finally {
            conn.disconnect(); // Ensure connection is closed
        }
    }
}
