package com.smartfridge.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartfridge.service.RecipeService;
import com.smartfridge.model.Recipe;

import java.util.List;

// Controlador REST para endpoints de receta
@RestController
@RequestMapping("/recipes") // Ruta base para las recetas
public class RecipeController { // Controlador de recetas
    @Autowired // Inyección del servicio de recetas
    private RecipeService recipeService; // Servicio de recetas
    // Obtiene recetas por id de usuario

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Recipe>> getRecipesByUser(@PathVariable int userId) {
        List<Recipe> recipes = recipeService.getRecipesByUserId(userId);
        return ResponseEntity.ok(recipes);
    }

    // Elimina receta por id y gestiona errores
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteRecipe(@PathVariable Integer id) {
        try {
            recipeService.deleteRecipeById(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            String msg = e.getMessage();
            if (msg == null || msg.isEmpty()) {
                msg = "Ha ocurrido un error inesperado. Inténtalo de nuevo más tarde.";
            }
            return ResponseEntity.badRequest().body(java.util.Map.of("message", msg));
        }
    }

    // Elimina recetas por id de usuario
    @DeleteMapping("/all/{userId}")
    public ResponseEntity<?> deleteAllRecipesByUserId(@PathVariable int userId) {
        recipeService.deleteAllByUserId(userId);
        return ResponseEntity.ok().build();
    }
}
