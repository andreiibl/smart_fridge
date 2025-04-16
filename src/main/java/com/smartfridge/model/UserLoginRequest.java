package com.smartfridge.model;
// Clase que representa los datos necesarios para iniciar sesión
public class UserLoginRequest {
    private String usernameOrEmail;
    private String password;
    // Getters y setters para cada campo
    public String getUsernameOrEmail() { return usernameOrEmail; }
    public void setUsernameOrEmail(String usernameOrEmail) { this.usernameOrEmail = usernameOrEmail; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
