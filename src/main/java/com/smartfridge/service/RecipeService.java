package com.smartfridge.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartfridge.model.Recipe;
import com.smartfridge.repository.RecipeRepository;

import java.util.List;

@Service // Marca la clase como servicio de Spring
public class RecipeService { // Servicio para lógica de recetas
    @Autowired // Inyección del repositorio
    private RecipeRepository recipeRepository; // Repositorio de recetas
    // Obtiene recetas por usuario
    public List<Recipe> getRecipesByUserId(int userId) { 
        return recipeRepository.findByUserId(userId);
    }
    // Elimina receta por id
    public void deleteRecipeById(Integer id) {
        if (!recipeRepository.existsById(id)) {
            throw new RuntimeException("La receta no existe");
        }
        recipeRepository.deleteById(id);
    }
}
