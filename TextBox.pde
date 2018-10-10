public class TextBox{
    float x, y, scale, w, h, blinkX;
    boolean clicked, blink, isInt;
    String text, plate;
    int limit;

    public TextBox(float x, float y, float scale, String plate){
        this.x = x;
        this.y = y;
        this.scale = scale;
        this.plate = plate;
        this.w = 150 * scale;
        this.h = 23 * scale;
        this.limit = 20;
        this.clicked = false;
        this.isInt = false;
        this.text = "";
        this.blink = true;
        this.blinkX = this.x;
        PFont font = createFont("AppleSDGothicNeo-Thin-48.vlw", 80);
        textFont(font);
    }

    public void show(){
        animate();
        noFill();
        strokeWeight(4);
        stroke(146,221,200);
        rectMode(CENTER);
        rect(x, y, w, h, 7);

        fill(255);
        textSize(12 * scale);
        textAlign(CENTER);
        text(text, x, y + (3 * scale));
        text(plate, x - (w/2 + textWidth(plate)/2 + 20), y + (3 * scale));

        if (blink && clicked){
            float yPos1 = y - (h/2 - 10) ;
            float yPos2 = y + (h/2 - 10);
            strokeWeight(2);
            line(blinkX, yPos1, blinkX, yPos2);
        }

        if(frameCount % 30 == 0){
            blink = !blink;
        }
    }

    public void setText(String s){
        text = s;
    }

    public void setLimit(int x){
        limit = x;
    }

    public void setInt(){
        isInt = true;
    }

    public void setClicked(){
        if (isHovered()){
            clicked = true;
            blink = true;
            return;
        }
        clicked = false;
    }

    public boolean isHovered(){
        if (mouseX > x - w/2 && mouseX < x + w/2){
            if (mouseY > y - h/2 && mouseY < y + h/2){
                return true;
            }
        }
        return false;
    }

    public void animate(){
        float difference = ((textWidth(text)/2) + 8 + x) - blinkX;
        //System.out.println(difference);

        if (difference >= 3){
            blinkX += 3;
            blink = true;
        }
        else if (difference <= -3){
            blinkX -= 3;
            blink = true;
        }
    }

    public void processKey(int code){
        if(clicked){
            //System.out.println((char) code);
            //Upper case
            if (text.length() < limit){
                if (code >= 65 && code <= 90 && !isInt){
                    text += (char) code;
                }
                //Lower case
                if (code >= 97 && code <= 122 && !isInt){
                    text += (char) code;
                }
                if (code >= 48 && code <= 57){
                    text += (char) code;
                }
                if (code == 46 && !isInt){
                    text += (char) code;
                }
            }
            if (code == 8){
                if (text.length() >= 1)
                    text = text.substring(0, text.length() - 1);
            }

            if (code == 10){
                //For the port
                if (isInt){
                    int tempNum = Integer.parseInt(text);
                    port = tempNum;
                }
                //For the player name
                else if (limit == 5){
                    playerName = text;
                }
                //For the IP address
                else{
                    address = text;
                }
                clicked = false;
                String[] tempData = {playerName, address, port + ""};
                saveStrings("Network.txt", tempData);
            }
         }
    }

}
