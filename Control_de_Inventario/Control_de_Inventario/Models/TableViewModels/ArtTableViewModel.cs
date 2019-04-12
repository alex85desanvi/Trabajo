using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Control_de_Inventario.Models.TableViewModels
{
    public class ArtTableViewModel
    {
        public int Id { get; set;}
        public string Nombre { get; set; }
        public decimal? Precio_Uni { get; set; }
        public decimal? Precio_Mayo_1 { get; set; }
        public decimal? Precio_Mayo_2 { get; set; }
    }
}