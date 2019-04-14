using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace Control_de_Inventario.Models.ViewModels
{
    public class UserViewModel
    {
        [Required]
        [StringLength(100,ErrorMessage = "El {0} debe tener al menos {1} caracteres",MinimumLength = 1)]
        [Display(Name = "Nombre de Usuario")]
        public string Usuario { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [Display(Name ="Contraseña")]
        public string Password { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [Display(Name ="Confirmar contraseña")]
        [Compare("Password",ErrorMessage = "Las contraseñas no son iguales")]
        public string ConfirmPassword { get; set; }

        [Required]
        [Display(Name = "Perfil")]
        public int Perfil { get; set; }
    }

    public class EditUserViewModel
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "El {0} debe tener al menos {1} caracteres", MinimumLength = 1)]
        [Display(Name = "Nombre de Usuario")]
        public string Usuario { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Contraseña")]
        public string Password { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Confirmar contraseña")]
        [Compare("Password", ErrorMessage = "Las contraseñas no son iguales")]
        public string ConfirmPassword { get; set; }

        [Display(Name = "Perfil")]
        public int Perfil { get; set; }
    }

    public class DeleteUserModel
    {
        public int Id { get; set; }
    }
}