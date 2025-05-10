package com.smartfridge.controller;

import com.smartfridge.model.Product;
import com.smartfridge.model.Recipe;
import com.smartfridge.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/products")
// Controlador para endpoints de productos
public class ProductController {

    @Autowired
    private ProductService productService; // Servicio de productos

    @GetMapping
    // Obtener todos los productos
    public List<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    @GetMapping("/{id}")
    // Obtener un producto por ID
    public Product getProductById(@PathVariable int id) {
        return productService.getProductById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    // Crear un producto
    public Product createProduct(@RequestBody Product product) {
        return productService.saveProduct(product);
    }

    @PutMapping("/{id}")
    // Actualizar un producto existente
    public Product updateProduct(@PathVariable int id, @RequestBody Product productDetails) {
        return productService.updateProduct(id, productDetails);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    // Eliminar un producto por ID
    public void deleteProduct(@PathVariable int id) {
        productService.deleteProduct(id);
    }

    @GetMapping("/search/name")
    // Buscar productos por nombre
    public List<Product> getProductsByName(@RequestParam String name) {
        return productService.getProductsByName(name);
    }

    @GetMapping("/search/category")
    // Buscar productos por categoría
    public List<Product> getProductsByCategory(@RequestParam String category) {
        return productService.getProductsByCategory(category);
    }

    @GetMapping("/search/nameOrCategory")
    // Buscar productos por nombre o categoría
    public List<Product> getProductsByNameOrCategory(@RequestParam String name, @RequestParam String category) {
        return productService.getProductsByNameOrCategory(name, category);
    }

    @GetMapping("/search/user/{userId}")
    // Buscar productos de un usuario específico
    public List<Product> getProductsByUser(@PathVariable int userId) {
        return productService.getProductsByUser(userId);
    }

    @GetMapping("/search/expDate")
    // Buscar productos que expiran antes de una fecha dada
    public List<Product> getProductsByExpDate(@RequestParam String expDate) {
        return productService.getProductsByExpDate(expDate);
    }

    @PostMapping("/generate-recipe/{userId}")
    // Generar receta a partir de los productos del usuario
    public Recipe generateRecipe(@PathVariable int userId) {
        System.out.println("Invocando generateRecipeFromProducts con userId: " + userId);
        return productService.generateRecipeFromProducts(userId);
    }

    @PostMapping("/update-quantities")
    // Actualizar cantidades de productos tras usar ingredientes en una receta
    public ResponseEntity<?> updateQuantities(@RequestBody Map<String, String> body) {
        try {
            String ingredientes = body.get("ingredientes");
            productService.updateStockIngredients(ingredientes);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            String msg = e.getMessage();
            if (msg == null || msg.isEmpty()) {
                msg = e.getClass().getSimpleName();
            }
            return ResponseEntity.badRequest().body(Map.of("message", msg));
        }
    }
}
