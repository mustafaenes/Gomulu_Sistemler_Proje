module LightControl (
  input wire clk,              // saat sinyali
  input wire button,           // açma/kapatma düğmesi
  input wire[3:0] hour,        // saat bilgisi
  output reg led_red,          // Kırmızı LED çıkışı
  output reg led_blue,         // Mavi LED çıkışı
  output reg led_green,        // Yeşil LED çıkışı
  output reg [3:0] case_state
);

  // Durum tanımlamaları
  reg [3:0] next_state;
  reg [3:0] current_state;

  // Zaman sayaçları
  reg [19:0] yellow_counter;
  reg [19:0] purple_counter;
  
  // Zaman parametrelerini tanımlıyoruz
  parameter [3:0] START_HOUR = 20; // Başlangıç saatini belirliyoruz
  parameter [3:0] END_HOUR = 23;   // Bitiş saatini belirliyoruz
  parameter [19:0] MINUTE_COUNT = 60000; // LED'in yanma süresini belirliyoruz (60 saniye x 1000)

  always @(posedge clk) begin
    current_state <= next_state;

    case (current_state)
      4'b0000: begin
        if (button == 1'b1) next_state <= 4'b0001;
      end
      4'b0001: begin
        if (button == 1'b1) next_state <= 4'b0010;
      end
      4'b0010: begin
        if (button == 1'b1) next_state <= 4'b0011;
      end
      4'b0011: begin
        if (button == 1'b1) next_state <= 4'b0000;
      end
      default: next_state <= 4'b0000;
    endcase

  end

  always @(posedge clk) begin
    case_state <= current_state;
  end

  always @(posedge clk) begin
    case (current_state)
      4'b0000: 
        begin
          led_red <= 0;
          led_green <= 0;
          led_blue <= 0;
        end
      4'b0001: 
        begin
          led_red <= 0;
          led_blue <= 1;
          led_green <= 0;
        end
      4'b0010: 
        begin
          led_red <= 0;
          led_green <= 0;
          led_blue <= 0;
        end
      4'b0011: 
        begin
          led_red <= 0;
          led_blue <= 0;
          led_green <= 1;
        end
      default: 
        begin
          led_red <= 0;
          led_green <= 1;
          led_blue <= 1;
        end
    endcase
  end
  

  always @(posedge clk) begin
    if (hour >= START_HOUR && hour <= END_HOUR) begin
      case (current_state)
        4'b0000, 4'b0010: begin
          if (yellow_counter < MINUTE_COUNT)
            yellow_counter <= yellow_counter + 1;
          else begin
            yellow_counter <= 0;
            next_state <= 4'b0001;
          end
        end
        4'b0001, 4'b0011: begin
          if (purple_counter < MINUTE_COUNT)
            purple_counter <= purple_counter + 1;
          else begin
            purple_counter <= 0;
            next_state <= 4'b0000;
          end
        end
        default: begin
          yellow_counter <= 0;
          purple_counter <= 0;
        end
      endcase
    end
    else begin
      yellow_counter <= 0;
      purple_counter <= 0;
    end
  end

  
endmodule
