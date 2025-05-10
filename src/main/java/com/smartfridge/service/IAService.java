package com.smartfridge.service;

import com.smartfridge.model.Recipe;
import com.smartfridge.model.User;
import com.smartfridge.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
// Servicio para generar recetas usando la API de Gemini
public class IAService {

    private final WebClient webClient; // Cliente HTTP para llamadas a la API

    @Value("${google.api.key}")
    private String apiKey; // Clave de API de Google

    @Autowired
    private UserRepository userRepository; // Repositorio de usuarios

    // Constructor que configura el WebClient con la URL base de Gemini
    public IAService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.baseUrl("https://generativelanguage.googleapis.com/v1beta").build();
    }

    // Genera una receta a partir de un prompt y el id de usuario
    public Recipe generateRecipe(String prompt, int userId) {
        try {
            Map<String, Object> requestBody = Map.of(
                    "contents", List.of(
                            Map.of(
                                    "parts", List.of(
                                            Map.of("text", prompt)))));
            String response = webClient.post()
                    .uri("/models/gemini-2.0-flash:generateContent?key=" + apiKey)
                    .header("Content-Type", "application/json")
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();
            return parseRecipe(response, userId); // Procesa la respuesta y devuelve la receta
        } catch (Exception e) {
            System.err.println("Error al generar la receta: " + e.getMessage());
            throw new RuntimeException("Error al generar la receta", e);
        }
    }

    // Limpia el texto eliminando caracteres innecesarios
    private String limpiarTexto(String texto) {
        if (texto == null)
            return "";
        return texto.replaceAll("[#*]{2,}|-{2,}|\\*", "").trim();
    }

    // Parsea la respuesta de Gemini y construye un objeto Recipe
    private Recipe parseRecipe(String response, int userId) {
        Recipe recipe = new Recipe();
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(response);
            JsonNode candidatesNode = rootNode.path("candidates");

            if (candidatesNode.isArray() && candidatesNode.size() > 0) {
                JsonNode contentNode = candidatesNode.get(0).path("content").path("parts").get(0).path("text");
                String recipeText = contentNode.asText();

                String[] lines = recipeText.split("\n");
                StringBuilder ingredients = new StringBuilder();
                StringBuilder steps = new StringBuilder();
                boolean isIngredientsSection = false;
                boolean isStepsSection = false;

                for (String line : lines) {
                    line = line.trim();
                    if (line.isEmpty())
                        continue;

                    String lowerLine = line.toLowerCase();

                    // Obtiene el nombre de la receta
                    if (lowerLine.startsWith("* titulo:") || lowerLine.startsWith("titulo:")) {
                        String name = line.replaceAll("(?i)\\*?\\s*titulo:\\s*", "");
                        recipe.setName(limpiarTexto(name));
                    }
                    // Obtiene la descripción corta
                    else if (lowerLine.startsWith("* breve descripcion:") || lowerLine.startsWith("breve descripcion:")
                            ||
                            lowerLine.startsWith("* breve descripción:")
                            || lowerLine.startsWith("breve descripción:")) {
                        String desc = line.replaceAll("(?i)\\*?\\s*breve descripci[oó]n:\\s*", "");
                        recipe.setShortDesc(limpiarTexto(desc));
                    }
                    // Marca el inicio de la sección de ingredientes
                    else if (lowerLine.startsWith("* ingredientes:") || lowerLine.startsWith("ingredientes:")) {
                        isIngredientsSection = true;
                        isStepsSection = false;
                        continue;
                    }
                    // Marca el inicio de la sección de pasos
                    else if (lowerLine.startsWith("* pasos a seguir:") || lowerLine.startsWith("pasos a seguir:")) {
                        isIngredientsSection = false;
                        isStepsSection = true;
                        continue;
                    }
                    // Añade ingredientes
                    else if (isIngredientsSection && !lowerLine.startsWith("* pasos a seguir:")
                            && !lowerLine.startsWith("pasos a seguir:")) {
                        String cleanLine = line.replaceAll("\\*", "").trim();
                        if (!cleanLine.isEmpty()) {
                            ingredients.append(cleanLine).append("\n");
                        }
                    }
                    // Añade pasos
                    else if (isStepsSection) {
                        String cleanLine = line.replaceAll("\\*\\*.*?:\\*\\*", "").trim();
                        if (!cleanLine.isEmpty()) {
                            steps.append(cleanLine).append("\n");
                        }
                    }
                }

                String cleanIngredients = limpiarTexto(ingredients.toString().trim());
                recipe.setIngredients(cleanIngredients);

                String cleanSteps = limpiarTexto(steps.toString().trim());
                recipe.setSteps(cleanSteps);

                recipe.setCreateDate(LocalDate.now().toString()); // Asigna la fecha actual

                // Busca y asigna el usuario a la receta
                User user = userRepository.findById(userId)
                        .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + userId));
                recipe.setUser(user);

                return recipe;
            }

            throw new RuntimeException("No se encontró contenido válido en la respuesta");

        } catch (Exception e) {
            System.err.println("Error al parsear la respuesta de Gemini: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error al parsear la respuesta de Gemini", e);
        }
    }

}
