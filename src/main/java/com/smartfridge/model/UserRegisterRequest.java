package com.smartfridge.model;
// Clase que representa los datos requeridos para registrar un nuevo usuario
public class UserRegisterRequest {
    private String name;
    private String username;
    private String email;
    private String password;
    // Constructor vacío requerido por Spring para deserializar JSON
    public UserRegisterRequest() {}
    // Getters y setters para cada campo
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}