{
  uiLovelace = {
    views = [
      {
        title = "Home";
        path = "home";
        cards = [
          {
            type = "entities";
            title = "Sensors";
            entities = [
              "sensor.temperature"
              "sensor.humidity"
            ];
          }
        ];
      }
    ];
  };
}
