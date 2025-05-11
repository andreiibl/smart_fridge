package com.smartfridge.controller;

import com.smartfridge.model.User;
import com.smartfridge.model.UserLoginRequest;
import com.smartfridge.model.UserRegisterRequest;
import com.smartfridge.repository.UserRepository;
import com.smartfridge.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController // Controlador REST para manejar peticiones relacionadas con usuarios
@RequestMapping("/users") // Prefijo comun para todas las rutas de este controlador
@CrossOrigin(origins = "http://localhost:3000") // Permite solicitudes CORS desde el frontend
public class UserController {
    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/login") // Endpoint POST para iniciar sesion
    public ResponseEntity<?> login(@RequestBody UserLoginRequest loginRequest) {
        Optional<User> optionalUser = userService.authenticateUser(
                loginRequest.getUsernameOrEmail(),
                loginRequest.getPassword());

        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            user.setPassword(null);
            Map<String, Object> response = new HashMap<>();
            response.put("id", user.getId());
            response.put("username", user.getUsername());
            response.put("email", user.getEmail());
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciales inválidas"); // Error 401 si no se
                                                                                                  // autentica
        }
    }

    @PostMapping("/register") // Endpoint POST para registrar un nuevo usuario
    public ResponseEntity<?> register(@RequestBody UserRegisterRequest registerRequest) {
        try {
            // Verifica si el nombre de usuario ya está registrado
            if (userRepository.existsByUsername(registerRequest.getUsername())) {
                Map<String, String> errorBody = new HashMap<>();
                errorBody.put("message", "El nombre de usuario ya está en uso");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(errorBody);
            }

            // Verifica si el correo electrónico ya está registrado
            if (userRepository.existsByEmail(registerRequest.getEmail())) {
                Map<String, String> errorBody = new HashMap<>();
                errorBody.put("message", "El correo electrónico ya está en uso");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(errorBody);
            }

            // Si no existe, procedemos con el registro
            User user = userService.registerUser(registerRequest);
            user.setPassword(null);
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            // Otro error de validación lanzado manualmente desde el servicio
            Map<String, String> errorBody = new HashMap<>();
            errorBody.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(errorBody);
        } catch (Exception e) {
            // Error inesperado del servidor
            Map<String, String> errorBody = new HashMap<>();
            errorBody.put("message", "Error al registrar usuario");
            return ResponseEntity.internalServerError().body(errorBody);
        }
    }
    // Endpoint DELETE para eliminar un usuario y sus datos relacionados
    @DeleteMapping("/delete/{userId}") 
    public ResponseEntity<?> deleteUserAndData(@PathVariable int userId) {
        userService.deleteUserAndRelatedData(userId);
        return ResponseEntity.ok().build();
    }
    // Endpoint PUT para cambiar la contraseña de un usuario
    @PutMapping("/change-password/{userId}")
    public ResponseEntity<?> changePassword(@PathVariable int userId, @RequestBody Map<String, String> body) {
        String newPassword = body.get("newPassword");
        userService.changePassword(userId, newPassword);
        return ResponseEntity.ok().build();
    }
}