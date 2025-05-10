package com.smartfridge.repository;

import com.smartfridge.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Integer> {
    
    // Buscar productos por nombre
    List<Product> findByName(String name);

    // Buscar productos por categoría
    List<Product> findByCategory(String category);

    // Buscar productos por nombre o categoría
    List<Product> findByNameOrCategory(String name, String category);
    
    // Buscar productos por id de usuario
    List<Product> findByUserId(int userId);

    // Buscar productos con fecha de expiración anterior a una fecha dada
    List<Product> findByExpDateBefore(String expDate);

    // Buscar productos por nombre sin importar mayúsculas o minúsculas
    List<Product> findByNameIgnoreCase(String name);
}
