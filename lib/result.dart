class Result {
  String species;
  String prediction;
  double pred;
  String description;
  String image;
  Result(this.species, double prediction, this.description, this.image) {
    this.pred = prediction;
    this.prediction = (100 * prediction).toInt().toString() + '%';
  }
  Map toJson() => {
        'species': species,
        'prediction': pred,
        'description': description,
        'image': image
      };
}
