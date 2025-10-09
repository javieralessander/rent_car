import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoliticsAndPrivacy extends StatelessWidget {
  const PoliticsAndPrivacy({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: politicsAndPrivacy.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            politicsAndPrivacy[index]['title']!,
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ), // Ajusta este valor según tus necesidades
            child: Text(
              politicsAndPrivacy[index]['body']!,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

List<Map<String, String>> politicsAndPrivacy = [
  {'title': '1. Datos del proveedor del servicio:', 'body': 'Jeely Store'},
  {
    'title': '2. Descripción del Servicio y la Plataforma:',
    'body':
        'Jeely Store es una plataforma para la compra en línea de productos ofrecidos por la tienda Jeely Store. Jeely Stre está conformada por las interfaces electrónicas y aplicación móvil nativa (Apple: App Store, Google: Play Store) a las que tiene acceso el Usuario y los componentes de entrega a domicilio (Delivery) y gestión interna (Back-Office) del equipo del Proveedor dedicado a la prestación del Servicio en sus distintas etapas (la Plataforma).',
  },
  {
    'title': '3. Aceptación de los términos:',
    'body':
        'Con el registro en la Plataforma el Usuario declara que ha leído y ponderado los Términos y Condiciones que regirán su interacción con la misma y que ha entendido y está de acuerdo con los mismos. Si no está de acuerdo con los Términos y Condiciones, el Usuario tiene la opción de no utilizar la Plataforma. El desconocimiento de los Términos y Condiciones no justificará su incumplimiento, ni la interposición de medidas legales en contravención o desconocimiento de los mismos. Las modificaciones a estos Términos y Condiciones serán notificadas al Usuario previo a su implementación, vía correo electrónico, mensaje de texto al teléfono provisto.',
  },
  {
    'title': '4. Validez de la comunicación electrónica:',
    'body':
        'Desde el primer momento en que visite la Plataforma, el Usuario está manifestando su conformidad con iniciar y mantener la comunicación electrónica como la vía de comunicación principal con el Proveedor. Las comunicaciones electrónicas relativas al uso del Servicio, tales como registros de actividad en la Plataforma, correos electrónicos, mensajes de texto SMS o por aplicaciones de mensajería electrónica y chats, se considerarán comunicaciones electrónicas válidas, legalmente vinculantes y satisfactorias como medios de prueba de las distintas interacciones o eventualidades que ocurran en el marco de la prestación del Servicio.',
  },
  {
    'title': '5. Registro en la plataforma:',
    'body':
        'Para utilizar el Servicio es necesario registrarse y validar una Cuenta de Usuario. Solo una persona física podrá registrarse como Usuario. Debe ser una persona mayor de edad de acuerdo con la mayoría legal establecida por las leyes de la República Dominicana, lo cual será verificado cuando el Usuario cargue su documento de identidad en el momento del registro. El uso de la Plataforma por una persona menor de edad no está permitido. Las consecuencias pecuniarias del uso no autorizado de la Plataforma por parte de una persona menor de edad serán asumidas por quienes ejerzan la autoridad parental sobre ésta, conforme lo establecen las leyes dominicanas. El registro es único y gratuito. El proceso de registro inicia con la solicitud de creación de Cuenta ingresando sus datos personales en la Plataforma y culmina con el proceso de verificación y validación de la Cuenta de Usuario. Para el registro en la Plataforma se requiere que el Usuario suministre datos personales necesarios para el correcto funcionamiento del Servicio, tales como: nombres y apellidos, número y documento de identificación personal vigente (cédula de identidad o pasaporte), dirección del domicilio, números telefónicos de contacto, fecha de nacimiento, dirección de correo electrónico válida, numeración de medios de pago. Al registrarse, el Usuario declara que toda la información provista es válida y verdadera, de manera que no será necesario que el Proveedor haga validaciones de dicha información, aunque tendrá la facultad de hacerlo. El Usuario se compromete a mantener actualizada toda la información provista. La Cuenta de Usuario estará protegida por una clave elegida por el Usuario, la cual deberá contar con rasgos mínimos de seguridad de acuerdo con las mejores prácticas recomendadas. El Usuario será responsable de mantener la Clave de manera confidencial, así como del uso debido, diligente y correcto de la misma.',
  },
  {
    'title': '6. Uso aceptado:',
    'body':
        'La Plataforma está orientada al uso personal e individual, no comercial, por parte del Usuario. Todas las imágenes, textos, audios, descargas digitales, diseños, signos distintivos, compilaciones de data, códigos de programación, software y otros materiales que en su conjunto e individualmente conforman la estructura operativa y estética de la Plataforma (el Material), están protegidos por las leyes y convenios de propiedad industrial, derechos de autor de la República Dominicana. Este Material es propiedad y uso exclusivo del Proveedor. El uso, reproducción, distribución, publicidad o referencia no autorizada al Material está sujeto a sanciones conforme dispongan las leyes aplicables.',
  },
  {
    'title': '7. Uso no aceptado:',
    'body':
        'Se considera como uso no aceptado todo aquel que cause sobrecarga de la plataforma, las actividades ilícitas, pedidos falsos o hechos con dolo, pedidos automatizados o mediante bots, pedidos no autorizados en nombre de terceros), pedidos con objetivo comercial y Entregas Fallidas (descritas en el acápite 10) cuando las mismas sean reiteradas (dos veces o más, de manera consecutiva o alternada). El Proveedor tendrá la facultad de suspender o bloquear el uso de la Plataforma a aquellas Cuentas desde las cuales se sospeche o se haya realizado un uso no aceptado, lo cual será notificado al Usuario mediante correo electrónico a fin de que tome conocimiento.',
  },
  {
    'title': '8. Forma de utilizar la plataforma:',
    'body':
        'Una vez verificada y validada la Cuenta de Usuario, el Usuario podrá realizar sus compras. Al realizar el pedido el Usuario debe tener en cuenta revisar cuidadosamente: o Los artículos y cantidades elegidos o La dirección de entrega o El nombre del tercero autorizado a recibir el producto, si lo hubiere. o Datos del medio elegido para el pago. o Forma de facturación deseada. o Resumen de cargos. Al confirmar un pedido el Usuario está declarando estar de acuerdo con todos los parámetros allí indicados. El Usuario podrá dar seguimiento en tiempo real al estatus de su pedido en la pestaña “Mis Pedidos”. El Usuario tendrá la oportunidad de cancelar el pedido hasta el momento en que el Proveedor inicie a recolectar los productos del pedido (Picking), haciendo clic en la opción cancelar dentro de la pestaña de Seguimiento en Mis Pedidos. Una vez iniciado el proceso de Picking, el Usuario no podrá cancelar el pedido. La Plataforma indicará los límites que puedan aplicar a los pedidos, tales como montos y cantidades mínimas o máximas, así como cargos aplicables por el Servicio, si procedieran. Todo cargo será debidamente notificado y desglosado en la pantalla antes de que el Usuario confirme su pedido. Recibido un pedido, la Plataforma lo revisará y confirmará, haciendo un cargo por el total de la compra en la tarjeta indicada como medio de pago en el pedido. Este cargo será reversado y aplicado el correcto en caso de que el monto de la facturación final varíe, conforme lo explicado más adelante. El Proveedor podrá modificar el pedido del Cliente mediante la eliminación de artículos que no se encuentren disponibles en la tienda física o almacén al momento de recolectar el pedido del Usuario. Si sucediere esto, el monto correspondiente al artículo eliminado no será incluido en la factura final. Confirmados por la Plataforma los artículos que conformarán el pedido a entregar al Usuario, se hace la facturación final.',
  },
  {
    'title': '9. Pago y Facturación:',
    'body':
        'El pago será hecho mediante tarjeta de crédito o de débito registrada en la plataforma. El Usuario es responsable de utilizar medios de pago para los cuales se encuentre en plena capacidad de uso. Tipo de facturación: De manera preestablecida, la Plataforma emitirá una Factura de Consumo. Si el Usuario desea que recibir una Factura de Crédito Fiscal, deberá velar por registrar dicha condición en su Cuenta de Usuario. Una vez pagada la compra, el Usuario no podrá modificar el tipo de facturación.',
  },
  {
    'title': '10. Entrega:',
    'body':
        'Zona de Entrega: Serán las áreas geográficas de la República Dominicana habilitadas para la entrega de pedidos. La información sobre la Zona de Entrega estará disponible para su consulta en la Plataforma, así como en la página web y las redes sociales del Proveedor. Las actualizaciones a la Zona de Entrega serán avisadas por la Plataforma mediante avisos emergentes, así como notificadas por correo electrónico al Usuario. Lugar de Entrega: Será la dirección indicada por el Usuario al momento de colocar su pedido. Dicha dirección debe estar dentro de los límites de la Zona de Entrega. Forma de entrega: Las compras serán entregadas en el Lugar de Entrega, por personal identificado por parte del Proveedor o asociado a la Plataforma (Delivery), al Usuario o a la persona autorizada para recibirlo. Horario de entrega: El Horario de Entrega se indicará en la Plataforma. Queda entendido que estos horarios podrán variar conforme el Proveedor lo estime necesario de acuerdo a la congestión de sus operaciones, caso fortuito o eventos de fuerza mayor. Modo de entrega: La persona encargada por el Proveedor para realizar la entrega del pedido del Usuario se desplazará al Lugar de Entrega y entregará al Usuario o al tercero debidamente identificado por el Usuario como autorizado para tal fin. Entregas fallidas: los pedidos que no logren ser entregados por estar dentro de uno de los escenarios debajo descritos, serán devueltos al Proveedor y anulados los cargos hechos a la tarjeta indicada por el Usuario, a saber: Tiempo de espera excedido: El Delivery esperará en el Lugar de Entrega por un tiempo máximo de 10 minutos. Usuario ilocalizable – En caso de que no se localice al Usuario o al tercero autorizado en el Lugar de Entrega, el Delivery se retirará del lugar con el pedido. Dirección no localizable – Cuando el personal de Delivery no logre localizar la dirección indicada por el Usuario. En los casos en que la entrega no sea realizada por causa imputable al Proveedor o la Plataforma, se procederá a la anulación del cargo a la tarjeta.',
  },
  {
    'title': '11. Reclamaciones y Devoluciones:',
    'body':
        'En caso de cualquier inconveniente con su pedido, el Usuario puede dirigirse a los canales de comunicación habilitados para tales fines en la Plataforma. Si es sobre un producto faltante o no conforme, debe notificarlo por dichas vías dentro de las siguientes 24 horas a la recepción. Si el Usuario desea realizar una devolución o cambio de uno de los productos recibidos, deberá acercarse al área de Servicio al Cliente de cualquiera de las sucursales de los Supermercados Bravo, dentro de los treinta (30) días posteriores a la compra, con el producto y la factura, ya sea original o en fotocopia o escaneada.',
  },
  {
    'title': '12. Información:',
    'body':
        'Las imágenes utilizadas en la Plataforma son para referencia y orientación del Usuario.',
  },
  {
    'title': '13. Política de Privacidad:',
    'body':
        'La información personal provista por el Usuario para poder ser identificado solo se empleará de acuerdo con los presentes Términos y Condiciones. INFORMACIÓN QUE ES RECOGIDA La Plataforma podrá recoger información personal tal como: nombres y apellidos, fecha de nacimiento, número de identificación personal, domicilio, teléfono, dirección de correo electrónico, información demográfica. Los datos personales de los Usuarios serán tratados conforme a los principios de licitud, consentimiento, información, calidad, finalidad, lealtad, proporcionalidad y responsabilidad. La Plataforma obtendrá, manejará y almacenará los datos obtenidos conforme establece la Ley No.172-13 sobre Protección de Datos de Carácter Personal de la República Dominicana. USO DE LA INFORMACIÓN RECOGIDA La Plataforma emplea la información para mejorar el servicio ofrecido, y particularmente para: mantener un registro de usuarios, de pedidos, realizar notificaciones, realizar el proceso de pago y facturación, trámites de servicio al cliente, conocer preferencias comerciales del usuario, mejoría de servicios, estadísticas y auditorías internas o externas, responder a requerimientos de las autoridades competentes. Es posible que sean enviados correos electrónicos periódicamente con información publicitaria que consideremos relevante al Usuario o que pueda brindarle algún beneficio. Si el Usuario ha consentido a recibir publicidad, estos correos electrónicos serán enviados a la dirección que usted proporcione y podrán ser cancelados en cualquier momento. ENLACES A TERCEROS Si la Plataforma tuviera enlaces a otros sitios, una vez que se haga clic en estos enlaces y se abandone la Plataforma, ya el Proveedor no tiene control sobre el sitio al que es redirigido el Usuario y por lo tanto no es responsable de los términos o privacidad ni de la protección de los datos del Usuario en esos otros sitios terceros. La Plataforma anunciará al Usuario que está abandonando su dominio para ingresar a uno de terceros, para que el Usuario acepte si prosigue o no. Dichos sitios están sujetos a sus propias políticas de privacidad por lo cual es recomendable que el Usuario los consulte para confirmar que está de acuerdo. CONTROL DE SU INFORMACIÓN PERSONAL El Proveedor no venderá, cederá ni distribuirá la información personal que es recopilada sin el consentimiento del usuario, salvo que sea requerido por las autoridades mediante orden judicial o administrativa.',
  },
  {
    'title': '14. Limitaciones de responsabilidad:',
    'body':
        'El Proveedor no puede garantizar que el funcionamiento de la Plataforma sea ininterrumpido o esté libre de errores, ni garantiza el funcionamiento de los servidores que alberguen la Plataforma, ya que los mismos son propiedad de terceros. La Plataforma avisará al Usuario por medios verificables en caso de que existan fallas o errores que impidan su uso. El Usuario será responsable por las consecuencias derivadas de su inobservancia de estos Términos y Condiciones.',
  },
  {
    'title': '15. Notificaciones, Resolución de conflictos:',
    'body':
        'Cualquier notificación de índole legal al Proveedor deberá ser hecha: Para el Proveedor: en el lugar de Domicilio Social o en la Tienda física establecidas en el territorio de la República Dominicana. Para el Usuario – en la dirección indicada al momento del registro. Además de los tribunales ordinarios de la República Dominicana competentes según la materia, serán también competentes para conocer todo conflicto relacionado con estos Términos y Condiciones las instituciones administrativas creadas al efecto.',
  },
];
