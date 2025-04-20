package com.smartfridge.service;

import com.smartfridge.model.Product;
import com.smartfridge.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository; // Repositorio para interactuar con la base de datos

    // Obtener todos los productos
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    // Obtener un producto por su ID
    public Product getProductById(Long id) {
        Optional<Product> product = productRepository.findById(id);
        return product.orElse(null);
    }

    // Crear o actualizar un producto
    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }

    // Actualizar un producto existente
    public Product updateProduct(Long id, Product productDetails) {
        Optional<Product> optionalProduct = productRepository.findById(id);

        if (optionalProduct.isPresent()) {
            Product product = optionalProduct.get();
            // Actualiza los campos del producto
            product.setName(productDetails.getName());
            product.setQuantity(productDetails.getQuantity());
            product.setTypeQuantity(productDetails.getTypeQuantity());
            product.setExpDate(productDetails.getExpDate());
            product.setCategory(productDetails.getCategory());
            product.setImageUrl(productDetails.getImageUrl());
            return productRepository.save(product);
        } else {
            return null;
        }
    }

    // Eliminar un producto por su ID
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    // Buscar productos por nombre
    public List<Product> getProductsByName(String name) {
        return productRepository.findByName(name);
    }

    // Buscar productos por categoría
    public List<Product> getProductsByCategory(String category) {
        return productRepository.findByCategory(category);
    }

    // Buscar productos por nombre o categoría
    public List<Product> getProductsByNameOrCategory(String name, String category) {
        return productRepository.findByNameOrCategory(name, category);
    }

    // Buscar productos de un usuario específico
    public List<Product> getProductsByUser(Long userId) {
        return productRepository.findByUserId(userId);
    }

    // Buscar productos que expiran antes de una fecha dada
    public List<Product> getProductsByExpDate(String expDate) {
        return productRepository.findByExpDateBefore(expDate);
    }
}
