public class Ship{
    float x, y, size, angle, turnRadius, deRate;
    ArrayList<Character> pressedChars;
    ArrayList<Bullet> bullets;
    boolean turn, accelerate;
    char k;
    PVector velocity;

    /**
     * Constuctor for the ship class.
     */
    public Ship(){
        //X and Y for the ship.
        x = width/2;
        y = height/2;
        //Size of the ship.
        size = 20;
        angle = 0;
        turnRadius = 0.08;
        deRate = 0.05;
        turn = false;
        accelerate = false;
        //ArrayList for the current pressed characters.
        //(Mainly used for making turning less janky.)
        pressedChars = new ArrayList<Character>();

        bullets = new ArrayList<Bullet>();
        velocity = new PVector();
    }

    /**
     * Removes one of the current pressed characters from the Array.
     * If there are no characters left then we stop turning.
     * @param k key entered by the user.
     */
    public void freezeTurn(char k){

        //Loop through and find characters we should remove.
        for (int i = pressedChars.size() - 1; i >= 0; i--){
            if (pressedChars.get(i) == k){
                pressedChars.remove(i);
            }
        }

        //If there are no more charaters then we should stop turning.
        if(pressedChars.size() < 1)
            turn = false;
    }

    /**
     * Tell the ship to start to turn in the appropriate direction.
     * @param k key entered by the user.
     */
    public void setTurn(char k){
        turn = true;
        this.k = Character.toLowerCase(k);
        pressedChars.add(this.k);
    }

    /**
     * Turn the ship X radians.
     */
    public void turn(){
        //Make sure we are in the scene and we should be turning.
        if (scene == 1 && turn){
            if (k == 'a'){
                angle -= turnRadius;
            }
            if (k == 'd'){
                angle += turnRadius;
            }
        }
    }

    /**
     * Bound the player to stay inside of the screen.
     */
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

    /**
     * Move in the direction of the current velocity.
     */
    public void move(){
        x += velocity.x;
        y += velocity.y;

        //Adds "friction" to slow down the ship.
        velocity.mult(0.99);
    }

    /**
     * Accelerates the ship in the current faced direction.
     */
    public void accelerate(){
        if (accelerate){
            PVector force = PVector.fromAngle(angle - PI/2);
            //Limit how strong the force is.
            force.mult(0.08);
            velocity.add(force);
        }
    }

    /**
     * Display the bullets and remove if out of the screen.
     */
    public void showBullets(){
        for (int i = bullets.size() - 1; i >= 0; i--){
            Bullet b = bullets.get(i);
            b.show();

            //If the bullet is out of the screen then we want to remove it.
            if (b.bound())
                bullets.remove(i);
        }
    }

    /**
     * Display the ship to the screen.
     */
    public void show(){
        pushMatrix();
        //Display the bullets
        showBullets();

        //Edit pos of the ship.
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

    /**
     * Handle the button pressed by the user.
     * @param k key entered by the user.
     */
    public void processButtonPress(char k){
        k = Character.toLowerCase(k);
        if (k == 'a' || k == 'd'){
            setTurn(k);
        }

        if (k == 'w'){
            accelerate = true;
        }

        if (k == ' '){
            bullets.add(new Bullet(x, y, angle));
        }
    }

    /**
     * Handle the button released by the user.
     * @param k key entered by the user.
     */
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
