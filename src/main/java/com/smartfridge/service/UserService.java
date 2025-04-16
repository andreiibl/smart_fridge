package com.smartfridge.service;

import com.smartfridge.model.User;
import com.smartfridge.model.UserRegisterRequest;
import com.smartfridge.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
}
