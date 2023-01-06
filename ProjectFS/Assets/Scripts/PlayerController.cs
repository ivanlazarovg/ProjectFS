using System.Collections;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
	//Scriptable object which holds all the player's movement parameters. If you don't want to use it
	//just paste in all the parameters, though you will need to manuly change all references in this script

	//HOW TO: to add the scriptable object, right-click in the project window -> create -> Player Data
	//Next, drag it into the slot in playerMovement on your player

	public PlayerData Data;

	#region Variables
	//Components
	public Rigidbody rb { get; private set; }

	//Variables control the various actions the player can perform at any time.
	//These are fields which can are public allowing for other sctipts to read them
	//but can only be privately written to.
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
	public float LastPressedJumpTime { get; private set; }

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
	#endregion

	private void Awake()
	{
		rb = GetComponent<Rigidbody>();
	}

	private void Start()
	{
		SetGravityScale(Data.gravity);
		IsFacingRight = true;
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

		if (_moveInput.x != 0)
			CheckDirectionToFace(_moveInput.x > 0);

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
			if (Physics.OverlapBox(_groundCheckPoint.position, _groundCheckSize, Quaternion.identity, _groundLayer).Length != 0 && !IsJumping) //checks if set box overlaps with ground
			{
				print("isGrounded");
				LastOnGroundTime = Data.coyoteTime; //if so sets the lastGrounded to coyoteTime
			}
		}
		#endregion

		#region JUMP CHECKS
		if (IsJumping && rb.velocity.y < 0)
		{
			IsJumping = false;

			if (!IsWallJumping)
				_isJumpFalling = true;
		}

		if (IsWallJumping && Time.time - _wallJumpStartTime > Data.wallJumpTime)
		{
			IsWallJumping = false;
		}

		if (LastOnGroundTime > 0 && !IsJumping && !IsWallJumping)
		{
			_isJumpCut = false;

			if (!IsJumping)
				_isJumpFalling = false;
		}

		//Jump
		if (CanJump() && LastPressedJumpTime > 0)
		{
			IsJumping = true;
			IsWallJumping = false;
			_isJumpCut = false;
			_isJumpFalling = false;
			Jump();
		}
		//WALL JUMP
		/*else if (CanWallJump() && LastPressedJumpTime > 0)
		{
			IsWallJumping = true;
			IsJumping = false;
			_isJumpCut = false;
			_isJumpFalling = false;
			_wallJumpStartTime = Time.time;
			_lastWallJumpDir = (LastOnWallRightTime > 0) ? -1 : 1;

			WallJump(_lastWallJumpDir);
		}*/
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
			SetGravityScale(0);
		}
		else if (rb.velocity.y < 0 && _moveInput.y < 0)
		{
			//Much higher gravity if holding down
			SetGravityScale(Data.fastFallGravity);
			//Caps maximum fall speed, so when falling over large distances we don't accelerate to insanely high speeds
			rb.velocity = new Vector2(rb.velocity.x, Mathf.Max(rb.velocity.y, -Data.maxFastFallSpeed));
		}
		else if (_isJumpCut)
		{
			//Higher gravity if jump button released
			SetGravityScale(Data.jumpCutGravity);
			rb.velocity = new Vector2(rb.velocity.x, Mathf.Max(rb.velocity.y, -Data.maxFallSpeed));
		}
		else if ((IsJumping || IsWallJumping || _isJumpFalling) && Mathf.Abs(rb.velocity.y) < Data.jumpHangTimeThreshold)
		{
			SetGravityScale(Data.jumpHangGravity);
		}
		else if (rb.velocity.y < 0)
		{
			//Higher gravity if falling
			SetGravityScale(Data.fallGravity);
			//Caps maximum fall speed, so when falling over large distances we don't accelerate to insanely high speeds
			rb.velocity = new Vector2(rb.velocity.x, Mathf.Max(rb.velocity.y, -Data.maxFallSpeed));
		}
		else
		{
			//Default gravity if standing on a platform or moving upwards
			SetGravityScale(-10);
		}
		#endregion
	}

	private void FixedUpdate()
	{
		if (IsWallJumping)
			Run(Data.wallJumpRunLerp);
		else
			Run(1);

	}

	#region INPUT CALLBACKS
	//Methods which whandle input detected in Update()
	public void OnJumpInput()
	{
		LastPressedJumpTime = Data.jumpInputBufferTime;
	}

	public void OnJumpUpInput()
	{
		if (CanJumpCut())
			_isJumpCut = true;
	}
	#endregion

	public void SetGravityScale(float scale)
	{
		Physics.gravity = new Vector3(0f, scale, 0f);
	}

	private void Run(float lerpAmount)
	{
		//Calculate the direction we want to move in and our desired velocity
		float targetSpeed = _moveInput.x * Data.runMaxSpeed;
		//We can reduce our control using Lerp() - this smooths changes to are direction and speed
		targetSpeed = Mathf.Lerp(rb.velocity.x, targetSpeed, lerpAmount);

		float accelRate;

		//Gets an acceleration value based on if we are accelerating (includes turning) 
		//or trying to decelerate (stop). As well as applying a multiplier if we're air borne.
		if (LastOnGroundTime > 0)
			accelRate = (Mathf.Abs(targetSpeed) > 0.01f) ? Data.runAccelAmount : Data.runDeccelAmount;
		else
			accelRate = (Mathf.Abs(targetSpeed) > 0.01f) ? Data.runAccelAmount * Data.accelInAir : Data.runDeccelAmount * Data.deccelInAir;

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

		IsFacingRight = !IsFacingRight;
	}

	private void Jump()
	{
		//Ensures we can't call Jump multiple times from one press
		LastPressedJumpTime = 0;
		LastOnGroundTime = 0;

		#region Perform Jump
		//We increase the force applied if we are falling
		//This means we'll always feel like we jump the same amount 
		//(setting the player's Y velocity to 0 beforehand will likely work the same, but I find this more elegant :D)
		float force = Data.jumpForce;
		if (rb.velocity.y < 0)
			force -= rb.velocity.y;

		rb.AddForce(Vector3.up * force, ForceMode.Impulse);
		#endregion
	}

	/*private void WallJump(int dir)
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
			force.x -= rb.velocity.x;

		if (rb.velocity.y < 0) //checks whether player is falling, if so we subtract the velocity.y (counteracting force of gravity). This ensures the player always reaches our desired jump force or greater
			force.y -= rb.velocity.y;

		//Unlike in the run we want to use the Impulse mode.
		//The default mode will apply are force instantly ignoring masss
		rb.AddForce(force, ForceMode2D.Impulse);
		#endregion
	}*/

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
			Turn();
	}

	private bool CanJump()
	{
		return LastOnGroundTime > 0 && !IsJumping;
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

	/*private bool CanWallJumpCut()
	{
		return IsWallJumping && rb.velocity.y > 0;
	}

	public bool CanSlide()
	{
		if (LastOnWallTime > 0 && !IsJumping && !IsWallJumping && LastOnGroundTime <= 0)
			return true;
		else
			return false;
	}*/
	#endregion

}