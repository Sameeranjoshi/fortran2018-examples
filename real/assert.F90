module assert
! Gfortran >= 6 needed for ieee_arithmetic: ieee_is_nan

use, intrinsic:: iso_fortran_env, stderr=>error_unit
use, intrinsic:: ieee_arithmetic
implicit none
private

#if REALBITS==32
integer,parameter :: wp=real32
#elif REALBITS==64
integer,parameter :: wp=real64
#elif REALBITS==128
integer,parameter :: wp=real128
#endif

public :: wp,isclose, assert_isclose

contains

elemental logical function isclose(actual, desired, rtol, atol, equal_nan)
! inputs
! ------
! actual: value "measured"
! desired: value "wanted"
! rtol: relative tolerance
! atol: absolute tolerance
! equal_nan: consider NaN to be equal?
!
!  rtol overrides atol when both are specified
!
! https://www.python.org/dev/peps/pep-0485/#proposed-implementation
! https://github.com/PythonCHB/close_pep/blob/master/is_close.py

  real(wp), intent(in) :: actual, desired
  real(wp), intent(in), optional :: rtol, atol
  logical, intent(in), optional :: equal_nan

  real(wp) :: r,a
  logical :: n
  ! this is appropriate INSTEAD OF merge(), since non present values aren't defined.
  r = 1e-5_wp
  a = 0._wp
  n = .false.
  if (present(rtol)) r = rtol
  if (present(atol)) a = atol
  if (present(equal_nan)) n = equal_nan

  !print*,r,a,n,actual,desired

!--- sanity check
  if ((r < 0._wp).or.(a < 0._wp)) error stop 'invalid tolerance parameter(s)'
!--- equal nan
  isclose = n.and.(ieee_is_nan(actual).and.ieee_is_nan(desired))
  if (isclose) return
!--- Inf /= Inf, unequal NaN
  if (.not.ieee_is_finite(actual) .or. .not.ieee_is_finite(desired)) return
!--- floating point closeness check
  isclose = abs(actual-desired) <= max(r * max(abs(actual), abs(desired)), a)

end function isclose


impure elemental subroutine assert_isclose(actual, desired, rtol, atol, equal_nan, err_msg)
! inputs
! ------
! actual: value "measured"
! desired: value "wanted"
! rtol: relative tolerance
! atol: absolute tolerance
! equal_nan: consider NaN to be equal?
! err_msg: message to print on mismatch
!
! rtol overrides atol when both are specified

  real(wp), intent(in) :: actual, desired
  real(wp), intent(in), optional :: rtol, atol
  logical, intent(in), optional :: equal_nan
  character(*), intent(in), optional :: err_msg

  if (.not.isclose(actual,desired,rtol,atol,equal_nan)) then
    write(stderr,*) merge(err_msg,'',present(err_msg)),': actual',actual,'desired',desired
    error stop
  endif

end subroutine assert_isclose

end module assert
