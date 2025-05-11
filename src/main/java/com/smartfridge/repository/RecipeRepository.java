package com.smartfridge.repository;

import com.smartfridge.model.Recipe;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

// Repositorio JPA para Recipe.
public interface RecipeRepository extends JpaRepository<Recipe, Integer> {
    List<Recipe> findByUserId(int userId);// Busca recetas por id de usuario.

    void deleteByUserId(int userId); // Elimina recetas por id de usuario.
}
