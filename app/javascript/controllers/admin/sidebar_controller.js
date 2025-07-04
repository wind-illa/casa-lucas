import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  connect() {
    // Restaurar el estado de "active" según la URL al conectar
    this.updateActiveLinkBasedOnURL();

    // Escuchar los cambios en el historial de navegación (retroceder, adelantar, etc.)
    window.addEventListener("popstate", this.handlePopState.bind(this));

    // Escuchar el evento turbo:load para manejar la vista en nuevas páginas
    document.addEventListener("turbo:load", this.updateActiveLinkBasedOnURL.bind(this));
  }

  disconnect() {
    // Limpiar los eventos cuando el controlador se desconecte
    window.removeEventListener("popstate", this.handlePopState.bind(this));
    document.removeEventListener("turbo:load", this.updateActiveLinkBasedOnURL.bind(this));
  }

  // Activar el enlace y actualizar la URL
  activate(event) {
    event.preventDefault(); // Prevenir la acción predeterminada

    const targetUrl = event.currentTarget.getAttribute("href");

    // Marcar el enlace activo
    this.setActiveLink(event.currentTarget);

    // Usar Turbo para cambiar la vista sin recargar la página
    Turbo.visit(targetUrl);
  }

  // Marcar un solo enlace como activo
  setActiveLink(target) {
    this.linkTargets.forEach(link => link.classList.remove("active"));
    target.classList.add("active");
  }

  // Actualizar la URL sin recargar la página
  updateURL(url) {
    // Usamos Turbo para cambiar la URL sin recargar la página
    Turbo.visit(url);
    this.updateActiveLinkBasedOnURL(); // Actualizar el estado de los enlaces
  }



  // Actualizar el estado activo de los enlaces según la URL actual
  // updateActiveLinkBasedOnURL() {
  //   const currentUrl = window.location.pathname;

  //   // Verificar si el enlace tiene la URL que coincide con la actual o es un prefijo
  //   this.linkTargets.forEach(link => {
  //     link.classList.remove("active");
  //     const linkUrl = link.getAttribute("href");

  //     // Excluir rutas de "admin" de la coincidencia parcial
  //     if (
  //       (currentUrl === linkUrl || currentUrl.startsWith(linkUrl + "/")) &&
  //       !(linkUrl === "/admin" && currentUrl !== "/admin")
  //     ) {
  //       link.classList.add("active");
  //     }
  //   });
  // }

  updateActiveLinkBasedOnURL() {
    const currentUrl = window.location.pathname;

    // Definir las rutas relacionadas
    const relatedLinks = {
      "/admin/orders/home": [
        "/admin/orders/pagos",
        "/admin/orders/preparacion",
        "/admin/orders/finalizadas",
        "/admin/orders/pendientes",
      ],

      "/admin/users/clientes": [
        "/admin/users/admins",
        "/admin/users/", // Ruta base de "users", para activar cuando se accede a cualquier /admin/users/{id}
      ],

      "/admin/settings": [
        "/admin/shipping_methods",
        "/admin/payment_methods",
        "/admin/discount_ranges",
        "/admin/banners",
        "/admin/bank_accounts",
        "/admin/mercado_pago_tokens",
      ],
    };

    this.linkTargets.forEach(link => {
      link.classList.remove("active");
      const linkUrl = link.getAttribute("href");

      // Verificar coincidencia exacta o prefijo de la URL
      if (
        (currentUrl === linkUrl || currentUrl.startsWith(linkUrl + "/")) &&
        !(linkUrl === "/admin" && currentUrl !== "/admin")
      ) {
        link.classList.add("active");
      }

      // Verificar si la URL actual pertenece a alguna de las rutas relacionadas
      Object.keys(relatedLinks).forEach(parentRoute => {
        // Verifica que la URL actual empiece con alguna de las rutas relacionadas
        if (relatedLinks[parentRoute].some(route => currentUrl.startsWith(route)) && linkUrl === parentRoute) {
          link.classList.add("active");
        }

        // Manejar rutas dinámicas de /admin/users/{id}
        if (parentRoute === "/admin/users" && currentUrl.startsWith("/admin/users/")) {
          // Activa el enlace a "/admin/users" cuando se está en cualquier subruta dinámica de usuarios
          if (linkUrl === "/admin/users") {
            link.classList.add("active");
          }
        }
      });
    });
  }





  // Manejar el evento de retroceso o avance en la URL
  handlePopState(event) {
    // Solo actualizar el enlace activo si Turbo no está manejando el cambio de vista
    if (!Turbo.navigator.isNavigating) {
      this.updateActiveLinkBasedOnURL();
    }
  }
}
