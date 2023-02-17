using System.Collections;
using UnityEngine;

public class PlayerController : MonoBehaviour, IDataPersistence
{

	public PlayerData Data;

	#region Variables
	public Rigidbody rb { get; private set; }

	public bool IsFacingRight { get; private set; }
	public bool IsJumping { get; private set; }
	public bool IsWallJumping { get; private set; }
	public bool IsSliding { get; private set; }

	//Timers (also all fields, could be private and a method returning a bool could be used)
	public float LastOnGroundTime { get; private set; }
	public float LastOnWallTime { get; private set; }
	public float LastOnWallRightTime { get; private set; }
	public float LastOnWallLeftTime { get; private set; }

	//Jump
	private bool _isJumpCut;
	private bool _isJumpFalling;

	//Wall Jump
	private float _wallJumpStartTime;
	private int _lastWallJumpDir;

	private Vector2 _moveInput;
    private float _horizontalDirection;
    private float _verticalDirection;
    public float LastPressedJumpTime { get; private set; }

    [SerializeField] private float _dashSpeed = 15f;
    [SerializeField] private float _dashLength = .3f;
    [SerializeField] private float _dashBufferLength = .1f;
    private float _dashBufferCounter;
    private bool _isDashing;
    private bool _hasDashed;
    private bool _canDash => _dashBufferCounter > 0f && !_hasDashed;

    //Set all of these up in the inspector
    [Header("Checks")]
	[SerializeField] private Transform _groundCheckPoint;
	//Size of groundCheck depends on the size of your character generally you want them slightly small than width (for ground) and height (for the wall check)
	[SerializeField] private Vector3 _groundCheckSize = new Vector3(0.49f, 0.03f, 0);
	[Space(5)]
	[SerializeField] private Transform _frontWallCheckPoint;
	[SerializeField] private Transform _backWallCheckPoint;
	[SerializeField] private Vector3 _wallCheckSize = new Vector3(0.5f, 1f, 0);

	[Header("Layers & Tags")]
	[SerializeField] private LayerMask _groundLayer;
	[SerializeField] private LayerMask _mushroomLayer;

	[SerializeField] private Animator characterAnimator;
	public float _runMaxSpeed;
	private bool mushroomJumpTriggered = false;
	float mushroomJumpTimer = 0;
	public Transform rotatePoint;
	#endregion

	public void LoadData(GameData data)
    {
		this.transform.position = data.playerPosition;
    }

	public void SaveData(GameData data)
    {
		data.playerPosition = PlayerInteraction.instance.lastRespawnPoint.transform.position;
    }

	private void Awake()
	{
		rb = GetComponent<Rigidbody>();
	}

	private void Start()
	{
		SetGravity(Data.gravity);
		IsFacingRight = true;
		_runMaxSpeed = Data.runMaxSpeed;
	}

	private void Update()
	{
		#region TIMERS
		LastOnGroundTime -= Time.deltaTime;
		LastOnWallTime -= Time.deltaTime;
		LastOnWallRightTime -= Time.deltaTime;
		LastOnWallLeftTime -= Time.deltaTime;

		LastPressedJumpTime -= Time.deltaTime;
		#endregion

		#region INPUT HANDLER
		_moveInput.x = Input.GetAxisRaw("Horizontal");
		_moveInput.y = Input.GetAxisRaw("Vertical");

        _horizontalDirection = _moveInput.x;
        _verticalDirection = _moveInput.y;
		if (Input.GetKeyDown(KeyCode.V))
		{
			_dashBufferCounter = _dashBufferLength;
		}
		else
		{
			_dashBufferCounter -= Time.deltaTime;
		}


        if (CanDash())
        {
            StartCoroutine(Dash(_horizontalDirection));
        }

		if (_isDashing)
		{
            characterAnimator.SetBool("dash", true);
		}

        if (!_isDashing)
		{
			characterAnimator.SetBool("dash", false);
            if (_moveInput.x != 0)
            {
                CheckDirectionToFace(_moveInput.x > 0);
                if (!IsJumping)
                {
                    characterAnimator.SetBool("isRun", true);
                }
                else
                {
                    characterAnimator.SetBool("isRun", false);
                }
            }
            else
            {
                characterAnimator.SetBool("isRun", false);
            }


            if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.C) || Input.GetKeyDown(KeyCode.J))
            {
                OnJumpInput();
            }

            if (Input.GetKeyUp(KeyCode.Space) || Input.GetKeyUp(KeyCode.C) || Input.GetKeyUp(KeyCode.J))
            {
                OnJumpUpInput();
            }
            #endregion

            #region COLLISION CHECKS
            if (!IsJumping)
            {
                //Ground Check
                if (Physics.OverlapBox(_groundCheckPoint.position, _groundCheckSize/2, Quaternion.identity, _groundLayer).Length != 0 && !IsJumping) //checks if set box overlaps with ground
                {
                    LastOnGroundTime = Data.coyoteTime; //if so sets the lastGrounded to coyoteTime
                }
                characterAnimator.SetBool("isJump", false);

				if (((Physics.OverlapBox(_frontWallCheckPoint.position, _wallCheckSize/2, Quaternion.identity, _groundLayer).Length != 0 && IsFacingRight)
					|| (Physics.OverlapBox(_backWallCheckPoint.position, _wallCheckSize/2, Quaternion.identity, _groundLayer).Length != 0 && !IsFacingRight)) && !IsWallJumping)
				{
					LastOnWallRightTime = 0.01f;
				}

				//Right Wall Check
				if (((Physics.OverlapBox(_frontWallCheckPoint.position, _wallCheckSize/2, Quaternion.identity, _groundLayer).Length != 0 && !IsFacingRight)
					|| (Physics.OverlapBox(_backWallCheckPoint.position, _wallCheckSize/2, Quaternion.identity, _groundLayer).Length != 0 && IsFacingRight)) && !IsWallJumping)
				{
					LastOnWallLeftTime = 0.01f;
				}

                //Two checks needed for both left and right walls since whenever the play turns the wall checkPoints swap sides
                LastOnWallTime = Mathf.Max(LastOnWallLeftTime, LastOnWallRightTime);
            }
            else
            {
                characterAnimator.SetBool("isJump", true);
            }
            #endregion

            #region JUMP CHECKS
            if (IsJumping && rb.velocity.y < 0)
            {
                IsJumping = false;

				if (!IsWallJumping)
				{
					_isJumpFalling = true;
				}
            }

            if (IsWallJumping && Time.time - _wallJumpStartTime > Data.wallJumpTime)
            {
                IsWallJumping = false;
            }

            if (LastOnGroundTime > 0 && !IsJumping && !IsWallJumping)
            {
                _isJumpCut = false;

				if (!IsJumping)
				{
					_isJumpFalling = false;
				}
            }

            //Jump
            if (CanJump() && LastPressedJumpTime > 0)
            {
                IsJumping = true;
                IsWallJumping = false;
                _isJumpCut = false;
                _isJumpFalling = false;
                Jump(Data.jumpForce);
            }
            //WALL JUMP
            else if (CanWallJump() && LastPressedJumpTime > 0)
            {
                IsWallJumping = true;
                IsJumping = false;
                _isJumpCut = false;
                _isJumpFalling = false;
                _wallJumpStartTime = Time.time;
                _lastWallJumpDir = (LastOnWallRightTime > 0) ? -1 : 1;

                WallJump(_lastWallJumpDir);
            }
        }


        #endregion

        #region SLIDE CHECKS
        /*if (CanSlide() && ((LastOnWallLeftTime > 0 && _moveInput.x < 0) || (LastOnWallRightTime > 0 && _moveInput.x > 0)))
			IsSliding = true;
		else
			IsSliding = false;*/
        #endregion

        #region GRAVITY
        //Higher gravity if we've released the jump input or are falling
        if (IsSliding)
		{
			SetGravity(0);
		}
		else if (rb.velocity.y < 0 && _moveInput.y < 0)
		{
			//Much higher gravity if holding down
			SetGravity(Data.fastFallGravity);
			//Caps maximum fall speed, so when falling over large distances we don't accelerate to insanely high speeds
			rb.velocity = new Vector2(rb.velocity.x, Mathf.Max(rb.velocity.y, -Data.maxFastFallSpeed));
		}
		else if (_isJumpCut)
		{
			//Higher gravity if jump button released
			SetGravity(Data.jumpCutGravity);
			rb.velocity = new Vector2(rb.velocity.x, Mathf.Max(rb.velocity.y, -Data.maxFallSpeed));
		}
		else if ((IsJumping || IsWallJumping || _isJumpFalling) && Mathf.Abs(rb.velocity.y) < Data.jumpHangTimeThreshold)
		{
			SetGravity(Data.jumpHangGravity);
		}
		else if (rb.velocity.y < 0)
		{
			//Higher gravity if falling
			SetGravity(Data.fallGravity);
			//Caps maximum fall speed, so when falling over large distances we don't accelerate to insanely high speeds
			rb.velocity = new Vector2(rb.velocity.x, Mathf.Max(rb.velocity.y, -Data.maxFallSpeed));
		}
		else
		{
			//Default gravity if standing on a platform or moving upwards
			SetGravity(Data.gravity);
		}
		#endregion

		RayCastChecks();
	}

	private void FixedUpdate()
	{
		if (IsWallJumping)
		{
			Run(Data.wallJumpRunLerp);
		}
		else
		{
			Run(1);
		}


    }

	#region INPUT CALLBACKS
	//Methods which whandle input detected in Update()
	public void OnJumpInput()
	{
		LastPressedJumpTime = Data.jumpInputBufferTime;
	}

	public void OnJumpUpInput()
	{
		if (CanJumpCut() || CanWallJumpCut())
		{
			_isJumpCut = true;
		}
	}
	#endregion

	public void SetGravity(float scale)
	{
		Physics.gravity = new Vector3(0f, scale, 0f);
	}

	private void Run(float lerpAmount)
	{
		//Calculate the direction we want to move in and our desired velocity
		float targetSpeed = _moveInput.x * _runMaxSpeed;
		//We can reduce our control using Lerp() - this smooths changes to are direction and speed
		targetSpeed = Mathf.Lerp(rb.velocity.x, targetSpeed, lerpAmount);

		float accelRate;

		//Gets an acceleration value based on if we are accelerating (includes turning) 
		//or trying to decelerate (stop). As well as applying a multiplier if we're air borne.
		if (LastOnGroundTime > 0)
		{
			accelRate = (Mathf.Abs(targetSpeed) > 0.01f) ? Data.runAccelAmount : Data.runDeccelAmount;
		}
		else
		{
			accelRate = (Mathf.Abs(targetSpeed) > 0.01f) ? Data.runAccelAmount * Data.accelInAir : Data.runDeccelAmount * Data.deccelInAir;
		}

		//Increase the acceleration and maxSpeed when at the apex of their jump, makes the jump feel a bit more bouncy, responsive and natural
		if ((IsJumping || IsWallJumping || _isJumpFalling) && Mathf.Abs(rb.velocity.y) < Data.jumpHangTimeThreshold)
		{
			accelRate *= Data.jumpHangAccelerationMult;
			targetSpeed *= Data.jumpHangMaxSpeedMult;
		}

		//We won't slow the player down if they are moving in their desired direction but at a greater speed than their maxSpeed
		if (Data.doConserveMomentum && Mathf.Abs(rb.velocity.x) > Mathf.Abs(targetSpeed) && Mathf.Sign(rb.velocity.x) == Mathf.Sign(targetSpeed) && Mathf.Abs(targetSpeed) > 0.01f && LastOnGroundTime < 0)
		{
			accelRate = 0;
		}

		//Calculate difference between current velocity and desired velocity
		float speedDif = targetSpeed - rb.velocity.x;
		//Calculate force along x-axis to apply to thr player

		float movement = speedDif * accelRate;

		//Convert this to a vector and apply to rigidbody
		rb.AddForce(movement * Vector3.right);

		
	}

	private void Turn()
	{
		//stores scale and flips the player along the x axis, 
		Vector3 scale = transform.localScale;
		scale.x *= -1;
		transform.localScale = scale;
		Vector3 rotatePointScale = rotatePoint.localScale;
		rotatePointScale.x *= -1;
		rotatePoint.localScale = rotatePointScale;

		IsFacingRight = !IsFacingRight;
	}

	private void Jump(float force)
	{
		//Ensures we can't call Jump multiple times from one press
		LastPressedJumpTime = 0;
		LastOnGroundTime = 0;

		#region Perform Jump
		//We increase the force applied if we are falling
		//This means we'll always feel like we jump the same amount 
		//(setting the player's Y velocity to 0 beforehand will likely work the same, but I find this more elegant :D)

		if (rb.velocity.y < 0)
		{
			force -= rb.velocity.y;
		}

		rb.AddForce(Vector3.up * force, ForceMode.Impulse);
		#endregion
	}

    IEnumerator Dash(float x)
    {
        float dashStartTime = Time.time;
        _hasDashed = true;
        _isDashing = true;
        IsJumping = false;

        rb.velocity = Vector2.zero;
        rb.drag = 0f;

        Vector2 dir;
		if (x != 0f )
		{
			dir = new Vector2(x, 0f);
		}
		else
		{
			if (IsFacingRight)
			{
				dir = new Vector2(1f, 0f);
			}
			else
			{
				dir = new Vector2(-1f, 0f);
			}
		}

        while (Time.time < dashStartTime + _dashLength)
        {
            rb.velocity = dir.normalized * _dashSpeed;
            yield return null;
        }

        _isDashing = false;

        yield return new WaitForSeconds(1f);
		_hasDashed = false;

    }


    private void WallJump(int dir)
	{
		//Ensures we can't call Wall Jump multiple times from one press
		LastPressedJumpTime = 0;
		LastOnGroundTime = 0;
		LastOnWallRightTime = 0;
		LastOnWallLeftTime = 0;

		#region Perform Wall Jump
		Vector2 force = new Vector2(Data.wallJumpForce.x, Data.wallJumpForce.y);
		force.x *= dir; //apply force in opposite direction of wall

		if (Mathf.Sign(rb.velocity.x) != Mathf.Sign(force.x))
		{
			force.x -= rb.velocity.x;
		}

		if (rb.velocity.y < 0)
		{ //checks whether player is falling, if so we subtract the velocity.y (counteracting force of gravity). This ensures the player always reaches our desired jump force or greater
			force.y -= rb.velocity.y;
		}

		//Unlike in the run we want to use the Impulse mode.
		//The default mode will apply are force instantly ignoring masss
		rb.AddForce(force, ForceMode.Impulse);
		#endregion
	}

    #region OTHER MOVEMENT METHODS
    /*private void Slide()
	{
		//Works the same as the Run but only in the y-axis
		//THis seems to work fine, buit maybe you'll find a better way to implement a slide into this system
		float speedDif = Data.slideSpeed - RB.velocity.y;
		float movement = speedDif * Data.slideAccel;
		//So, we clamp the movement here to prevent any over corrections (these aren't noticeable in the Run)
		//The force applied can't be greater than the (negative) speedDifference * by how many times a second FixedUpdate() is called. For more info research how force are applied to rigidbodies.
		movement = Mathf.Clamp(movement, -Mathf.Abs(speedDif) * (1 / Time.fixedDeltaTime), Mathf.Abs(speedDif) * (1 / Time.fixedDeltaTime));

		RB.AddForce(movement * Vector2.up);
	}*/

    #endregion


    #region CHECK METHODS
    public void CheckDirectionToFace(bool isMovingRight)
	{
		if (isMovingRight != IsFacingRight)
		{
			Turn();
		}
	}

	private bool CanJump()
	{
		return LastOnGroundTime > 0 && !IsJumping && !_isDashing;
	}

	private bool CanWallJump()
	{
		return LastPressedJumpTime > 0 && LastOnWallTime > 0 && LastOnGroundTime <= 0 && (!IsWallJumping ||
			 (LastOnWallRightTime > 0 && _lastWallJumpDir == 1) || (LastOnWallLeftTime > 0 && _lastWallJumpDir == -1));
	}

	private bool CanJumpCut()
	{
		return IsJumping && rb.velocity.y > 0;
	}

	private bool CanDash()
	{
		return !IsJumping && !IsWallJumping && !_isJumpCut && !_isJumpFalling && LastOnGroundTime > 0 && _dashBufferCounter > 0f && !_hasDashed;
	}

	public void RayCastChecks()
    {
		RaycastHit hit;
		if (Physics.Raycast(_groundCheckPoint.position, -transform.up, out hit, 0.2f))
		{
			if(hit.collider.gameObject.GetComponent<FallingPlatform>() != null)
            {
				StartCoroutine(hit.collider.gameObject.GetComponent<FallingPlatform>().Fall());

			}
        }

	}

    private Vector2 GetInput()
    {
        return new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
    }

    private bool CanWallJumpCut()
	{
		return IsWallJumping && rb.velocity.y > 0;
	}

	public bool CanSlide()
	{
		if (LastOnWallTime > 0 && !IsJumping && !IsWallJumping && LastOnGroundTime <= 0)
			return true;
		else
			return false;
	}
    #endregion

}