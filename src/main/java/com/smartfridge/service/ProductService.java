package com.smartfridge.service;

import com.smartfridge.model.Product;
import com.smartfridge.model.Recipe;
import com.smartfridge.repository.ProductRepository;
import com.smartfridge.repository.RecipeRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
// Servicio para la gestión de productos y generación de recetas
public class ProductService {

    @Autowired
    private ProductRepository productRepository; // Repositorio para interactuar con la base de datos

    // Obtener todos los productos
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    // Obtener un producto por su ID
    public Product getProductById(int id) {
        Optional<Product> product = productRepository.findById(id);
        return product.orElse(null);
    }

    // Crear o actualizar un producto
    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }

    // Actualizar un producto existente
    public Product updateProduct(int id, Product productDetails) {
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
    public void deleteProduct(int id) {
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
    public List<Product> getProductsByUser(int userId) {
        return productRepository.findByUserId(userId);
    }

    // Buscar productos que expiran antes de una fecha dada
    public List<Product> getProductsByExpDate(String expDate) {
        return productRepository.findByExpDateBefore(expDate);
    }

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private IAService chatGPTService;

    // Genera una receta a partir de los productos del usuario
    public Recipe generateRecipeFromProducts(int userId) {
        List<Product> products = productRepository.findByUserId(userId);
        if (products.isEmpty()) {
            throw new IllegalArgumentException("No se encontraron productos para el usuario con ID: " + userId);
        }
        StringBuilder promptBuilder = new StringBuilder(
                "Genera una receta detallada con el siguiente formato y sigue estas instrucciones:\n");
        promptBuilder.append("* TITULO: [Título de la receta]\n");
        promptBuilder.append("* BREVE DESCRIPCION: [Descripción breve de la receta]\n");
        promptBuilder.append("* INGREDIENTES:\n");
        promptBuilder.append("- [Ingrediente 1]\n");
        promptBuilder.append("- [Ingrediente 2]\n");
        promptBuilder.append("* PASOS A SEGUIR:\n");
        promptBuilder.append("1. [Paso 1]\n");
        promptBuilder.append("2. [Paso 2]\n");
        promptBuilder.append(
            "\nIMPORTANTE: SOLO puedes usar los ingredientes y las cantidades que aparecen en la lista. " +
            "NO inventes ingredientes ni uses más cantidad de la que hay disponible. " +
            "Si no puedes crear una receta realista con los ingredientes y cantidades dadas, RESPONDE SOLO: '* TITULO: No se puede generar una receta con los ingredientes disponibles.' " +
            "En la lista de ingredientes, escribe SIEMPRE primero la cantidad y la unidad, seguido de 'de' y el nombre del ingrediente, por ejemplo: '200 gr de espagueti'. " +
            "No uses símbolos como ###, ---, ***, ni dobles asteriscos. Si quieres resaltar una sección, usa solo un asterisco al principio, por ejemplo: * INGREDIENTES. " +
            "Escribe los nombres exactamente como aparecen en la lista, sin tildes y sin añadir detalles extra (por ejemplo, si tienes 'Queso', solo pon 'Queso', no 'Queso de cabra'). " +
            "Indica SIEMPRE la cantidad de cada ingrediente usado en la receta. " +
            "NO añadas ningún ingrediente que no esté en la lista, excepto sal, pimienta, aceite o agua si es imprescindible y jamás indiques la cantidad de estos. " +
            "IMPORTANTE Y OBLIGATORIO: Usa únicamente los siguientes ingredientes, no es necesario usar todos, ni toda la cantidad, son de los que dispongo. " +
            "SI NO HAY SUFICIENTES INGREDIENTES PARA HACER UNA RECETA REALISTA, RESPONDE SOLO: '* TITULO: No se puede generar una receta con los ingredientes disponibles.'\n"
        );
        for (Product product : products) {
            promptBuilder.append("- ")
                    .append(product.getQuantity())
                    .append(" ")
                    .append(product.getTypeQuantity())
                    .append(" de ")
                    .append(product.getName())
                    .append("\n");
        }
        Recipe recipe = chatGPTService.generateRecipe(promptBuilder.toString(), userId);
        if (recipe.getName() != null && recipe.getName().trim().equalsIgnoreCase("No se puede generar una receta con los ingredientes disponibles.")) {
            throw new RuntimeException("No se puede generar una receta con los ingredientes disponibles.");
        }
        recipeRepository.save(recipe);
        return recipe;
    }

    // Actualiza el stock de ingredientes usados en una receta
    public void updateStockIngredients(String ingredientes) {
        String[] lines = ingredientes.split("\n");
        Pattern pattern = Pattern.compile("-\\s*(\\d+(?:[\\.,]\\d+)?)\\s*(\\w+)\\s+de\\s+(.+)",
                Pattern.CASE_INSENSITIVE);
        List<String> faltantes = new ArrayList<>();

        // Comprobar stock suficiente
        for (String line : lines) {
            Matcher matcher = pattern.matcher(line);
            if (matcher.find()) {
                double cantidad = Double.parseDouble(matcher.group(1).replace(",", "."));
                String nombre = matcher.group(3).trim();
                List<Product> productos = productRepository.findByNameIgnoreCase(nombre);
                if (productos.isEmpty() || productos.get(0).getQuantity() < cantidad) {
                    faltantes.add(nombre);
                }
            }
        }

        if (!faltantes.isEmpty()) {
            throw new RuntimeException("No hay suficiente cantidad de: " + String.join(", ", faltantes));
        }

        // Restar stock o eliminar si es 0 o menos
        for (String line : lines) {
            Matcher matcher = pattern.matcher(line);
            if (matcher.find()) {
                double cantidad = Double.parseDouble(matcher.group(1).replace(",", "."));
                String nombre = matcher.group(3).trim();
                List<Product> productos = productRepository.findByNameIgnoreCase(nombre);
                if (!productos.isEmpty()) {
                    Product producto = productos.get(0);
                    double nuevaCantidad = producto.getQuantity() - cantidad;
                    if (nuevaCantidad <= 0) {
                        productRepository.delete(producto);
                    } else {
                        producto.setQuantity(nuevaCantidad);
                        productRepository.save(producto);
                    }
                }
            }
        }
    }
}
