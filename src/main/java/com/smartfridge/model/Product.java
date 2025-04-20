package com.smartfridge.model;

import jakarta.persistence.*;

// Define la clase como una entidad JPA asociada a la tabla "products"
@Entity
@Table(name = "products")
public class Product {
    // Identificador único generado automáticamente
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    // Atributos de la entidad
    private String name;
    private Double quantity;
    private String typeQuantity;
    private String expDate;
    private String imageUrl;
    private String category;
    // Relación muchos-a-uno con la entidad User
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false) // Clave foránea que referencia a la tabla de usuarios
    private User user;

    // Getters y Setters
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Double getQuantity() {
        return quantity;
    }

    public void setQuantity(Double quantity) {
        this.quantity = quantity;
    }

    public String getTypeQuantity() {
        return typeQuantity;
    }

    public void setTypeQuantity(String typeQuantity) {
        this.typeQuantity = typeQuantity;
    }

    public String getExpDate() {
        return expDate;
    }

    public void setExpDate(String expDate) {
        this.expDate = expDate;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
