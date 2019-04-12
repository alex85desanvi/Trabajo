//Validaciones
using System.ComponentModel.DataAnnotations;

namespace Control_de_Inventario.Models.ViewModels
{
    public class ArtViewModel
    {   [Required]
        [StringLength(100,ErrorMessage ="El {0} debe tener al menos {1} caracteres",MinimumLength = 3)]
        [Display(Name ="Nombre de Producto")]
        public string Nombre { get; set; }

        [Display(Name ="Descripcion")]
        public string Descripcion { get; set; }

        [Required]
        [Display(Name = "Precio Unitario")]
        [DataType(DataType.Currency)]
        public decimal? Precio_Uni { get; set; }

        [Display(Name = "Precio Mayorista A")]
        [DataType(DataType.Currency)]
        public decimal? Precio_Mayo_1 { get; set; }

        [Display(Name = "Precio Mayorista B")]
        [DataType(DataType.Currency)]
        public decimal? Precio_Mayo_2 { get; set; }
    }

    public class EditArtViewModel
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "El {0} debe tener al menos {1} caracteres", MinimumLength = 3)]
        [Display(Name = "Nombre de Producto")]
        public string Nombre { get; set; }

        [Display(Name = "Descripcion")]
        public string Descripcion { get; set; }

        [Required]
        [Display(Name = "Precio Unitario")]
        [DataType(DataType.Currency)]
        public decimal? Precio_Uni { get; set; }

        [Display(Name = "Precio Mayorista A")]
        [DataType(DataType.Currency)]
        public decimal? Precio_Mayo_1 { get; set; }

        [Display(Name = "Precio Mayorista B")]
        [DataType(DataType.Currency)]
        public decimal? Precio_Mayo_2 { get; set; }
    }

    public class DeleteArtViewModel
    {
        public int Id { get; set;}
    }
}