class Solicitante {
  String nome;
  String email;
  String celular;

  Solicitante({this.nome, this.email, this.celular});

  Map<String, dynamic> toJson() {
    return {
      'nome': this.nome,
      'email': this.email,
      'celular': this.celular,
    };
  }
}
