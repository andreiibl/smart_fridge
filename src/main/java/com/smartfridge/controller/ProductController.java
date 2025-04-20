package com.smartfridge.controller;

import com.smartfridge.model.Product;
import com.smartfridge.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    // Obtener todos los productos
    @GetMapping
    public List<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    // Obtener un producto por ID
    @GetMapping("/{id}")
    public Product getProductById(@PathVariable Long id) {
        return productService.getProductById(id);
    }

    // Crear un producto
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Product createProduct(@RequestBody Product product) {
        return productService.saveProduct(product);
    }

    // Actualizar un producto existente
    @PutMapping("/{id}")
    public Product updateProduct(@PathVariable Long id, @RequestBody Product productDetails) {
        return productService.updateProduct(id, productDetails);
    }

    // Eliminar un producto por ID
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
    }

    // Buscar productos por nombre
    @GetMapping("/search/name")
    public List<Product> getProductsByName(@RequestParam String name) {
        return productService.getProductsByName(name);
    }

    // Buscar productos por categoría
    @GetMapping("/search/category")
    public List<Product> getProductsByCategory(@RequestParam String category) {
        return productService.getProductsByCategory(category);
    }

    // Buscar productos por nombre o categoría
    @GetMapping("/search/nameOrCategory")
    public List<Product> getProductsByNameOrCategory(@RequestParam String name, @RequestParam String category) {
        return productService.getProductsByNameOrCategory(name, category);
    }

    // Buscar productos de un usuario específico
    @GetMapping("/search/user/{userId}")
    public List<Product> getProductsByUser(@PathVariable Long userId) {
        return productService.getProductsByUser(userId);
    }

    // Buscar productos que expiran antes de una fecha dada
    @GetMapping("/search/expDate")
    public List<Product> getProductsByExpDate(@RequestParam String expDate) {
        return productService.getProductsByExpDate(expDate);
    }
}
