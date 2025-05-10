package com.smartfridge.model;

import jakarta.persistence.*;

//Entidad JPA que representa una receta.
@Entity // Indica que la clase es una entidad JPA.
@Table(name = "recipes") // Mapea la entidad a la tabla 'recipes'.
public class Recipe {

    @Id // Clave primaria de la entidad.
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Autoincremental.
    private int id;

    private String name; // Nombre de la receta.

    @Column(columnDefinition = "TEXT")
    private String shortDesc; // Descripción corta.

    @Column(columnDefinition = "TEXT")
    private String ingredients; // Ingredientes de la receta.

    @Column(columnDefinition = "TEXT")
    private String steps; // Pasos de la receta.

    private String createDate; // Fecha de creación.

    @ManyToOne // Relación muchos a uno con usuario.
    @JoinColumn(name = "user_id") // Columna de unión con la tabla usuario.
    private User user;

    // Métodos getter y setter para cada atributo.

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getShortDesc() { return shortDesc; }
    public void setShortDesc(String shortDesc) { this.shortDesc = shortDesc; }

    public String getIngredients() { return ingredients; }
    public void setIngredients(String ingredients) { this.ingredients = ingredients; }

    public String getSteps() { return steps; }
    public void setSteps(String steps) { this.steps = steps; }

    public String getCreateDate() { return createDate; }
    public void setCreateDate(String createDate) { this.createDate = createDate; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    // Representación en texto de la receta.
    @Override
    public String toString() {
        return "Recipe{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", shortDesc='" + shortDesc + '\'' +
                ", ingredients='" + ingredients + '\'' +
                ", steps='" + steps + '\'' +
                ", createDate='" + createDate + '\'' +
                ", user=" + (user != null ? user.getId() : "null") +
                '}';
    }
}