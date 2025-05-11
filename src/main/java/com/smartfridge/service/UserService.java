package com.smartfridge.service;

import com.smartfridge.model.User;
import com.smartfridge.model.UserRegisterRequest;
import com.smartfridge.repository.ProductRepository;
import com.smartfridge.repository.RecipeRepository;
import com.smartfridge.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service // Marca esta clase como un servicio de Spring
public class UserService 
{
    @Autowired
    private UserRepository userRepository;
    // Autentica a un usuario usando nombre de usuario o correo electronico
    public Optional<User> authenticateUser(String usernameOrEmail, String password) 
    {
        // Verifica si el input parece un email
        if (usernameOrEmail.contains("@")) 
        {
            Optional<User> userByEmail = userRepository.findByEmailAndPassword(usernameOrEmail, password);
            if (userByEmail.isPresent()) 
            {
                return userByEmail;
            }
        }
        // Si no es email o no encontro por email, busca por username
        return userRepository.findByUsernameAndPassword(usernameOrEmail, password);
    }
    // Registra un nuevo usuario en la base de datos
    public User registerUser(UserRegisterRequest registerRequest) 
    {
        User user = new User
        (
            registerRequest.getName(),
            registerRequest.getUsername(),
            registerRequest.getEmail(),
            registerRequest.getPassword()
        );
        return userRepository.save(user);
    }
    @Autowired
    private RecipeRepository recipeRepository;
    @Autowired
    private ProductRepository productRepository;
    @Transactional // Asegura que todas las operaciones se realicen como una transacción
    // Borra un usuario y sus recetas y productos relacionados
    public void deleteUserAndRelatedData(int userId) {
        // Primero borra recetas
        recipeRepository.deleteByUserId(userId);
        // Luego borra productos
        productRepository.deleteByUserId(userId);
        // Finalmente borra el usuario
        userRepository.deleteById(userId);
    }
    // Cambia la contraseña de un usuario
    public void changePassword(int userId, String newPassword) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setPassword(newPassword); // Recuerda encriptar si usas hashing
        userRepository.save(user);
    }
}
