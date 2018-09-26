public class Ship{
    float x, y, size, angle, turnRadius, deRate;
    ArrayList<Character> pressedChars;
    boolean turn, accelerate;
    char k;
    PVector velocity;

    public Ship(){
        x = width/2;
        y = height/2;
        size = 20;
        angle = 0;
        turnRadius = 0.08;
        deRate = 0.05;
        turn = false;
        accelerate = false;
        pressedChars = new ArrayList<Character>();
        velocity = new PVector();
    }

    public void freezeTurn(char k){
        for (int i = pressedChars.size() - 1; i >= 0; i--){
            if (pressedChars.get(i) == k){
                pressedChars.remove(i);
            }
        }

        if(pressedChars.size() < 1)
            turn = false;
    }

    public void setTurn(char k){
        turn = true;
        this.k = Character.toLowerCase(k);
        pressedChars.add(this.k);
    }

    public void turn(){
        if (scene == 1 && turn){
            if (k == 'a'){
                angle -= turnRadius;
            }
            if (k == 'd'){
                angle += turnRadius;
            }
        }
    }

    public void bound(){
        if (x + size < 0){
            x = width + size;
        }
        else if (x - size > width){
            x = 0 - size;
        }

        if (y + size < 0){
            y = height + size;
        }
        else if (y - size > height){
            y = 0 - size;
        }
    }

    public void move(){
        x += velocity.x;
        y += velocity.y;

        velocity.mult(0.99);
    }

    public void accelerate(){
        if (accelerate){
            PVector force = PVector.fromAngle(angle - PI/2);
            force.mult(0.08);
            velocity.add(force);
        }
    }

    public void show(){
        pushMatrix();

        turn();
        move();
        accelerate();
        bound();

        noFill();
        stroke(255);
        strokeWeight(3);
        translate(x, y);
        rotate(angle);

        triangle(-size, size, 0, -size - 5, size, size);

        popMatrix();
    }

    public void processButtonPress(char k){
        k = Character.toLowerCase(k);
        if (k == 'a' || k == 'd'){
            setTurn(k);
        }

        if (k == 'w'){
            accelerate = true;
        }
    }

    public void processButtonReleased(char k){
        k = Character.toLowerCase(k);
        if (k == 'a' || k == 'd'){
            freezeTurn(k);
        }
        if (k == 'w'){
            accelerate = false;
        }
    }
}
