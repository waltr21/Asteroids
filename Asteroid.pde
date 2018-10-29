public class Asteroid{
    float x, y, size, angle, maxLevel;
    int level;
    PVector velocity;

    /**
     * Constructor for the Asteroid class.
     * @param x     X pos of the asteroid
     * @param y     Y pos of the asteroid
     * @param level Level of asteroid (1-3)
     */
    public Asteroid(float x, float y, int level){
        this.x = x;
        this.y = y;
        this.size = 30 * level;
        this.level = level;
        this.maxLevel = 3;
        this.angle = random(-PI, PI);
        this.velocity = PVector.fromAngle(angle);
        this.velocity.mult( (float) ((maxLevel+1) - level) * 0.8);
    }

    public Asteroid(float x, float y, float a, int level){
        this.x = x;
        this.y = y;
        this.size = 30 * level;
        this.level = level;
        this.maxLevel = 3;
        this.angle = a;
        this.velocity = PVector.fromAngle(angle);
        this.velocity.mult(((maxLevel+1) - level) * 0.8);
    }


    /**
     * Bound the Asteroid to stay inside of the screen.
     */
    public void bound(){
        if (x + size < 0){
            x = width + size/2;
        }
        else if (x - size > width){
            x = 0 - size/2;
        }

        if (y + size < 0){
            y = height + size/2;
        }
        else if (y - size > height){
            y = 0 - size/2;
        }
    }

    public void travel(){
        x += velocity.x;
        y += velocity.y;
    }

    public void checkHit(){
        float distance = dist(x, y, player.getX(), player.getY());
        //System.out.println(distance);
        if (distance < size/2 + player.getSize()){
            player.setHit();
        }
    }

    public void explode(){
        if (level > 1){
            int index = asteroids.indexOf(this);
            for (int i = 0; i < 2; i++){
                Asteroid newAsteroid = new Asteroid(x, y, level - 1);
                asteroids.add(newAsteroid);
            }

            asteroids.remove(this);

        }

        else{
            asteroids.remove(this);
        }

        if (online){
            onlineScene.sendAllAsteroids();
        }
    }

    public int getScore(){
        if (level == 1)
            return 100;
        else if (level == 2)
            return 50;
        else
            return 20;

    }

    public void show(){
        pushMatrix();
        checkHit();
        travel();
        bound();
        noFill();
        stroke(255);
        ellipseMode(CENTER);
        translate(x, y);
        ellipse(0, 0, size, size);
        popMatrix();
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

    public int getLevel(){
        return level;
    }

    public float getAngle(){
        return angle;
    }

    public void setAngle(float a){
        angle = a;
    }

    public float getSize(){
        return size;
    }
}
